import 'package:flutter/material.dart';
import 'package:better_auth_client/better_auth_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final BetterAuthClient authClient;

  @override
  void initState() {
    super.initState();
    authClient = BetterAuthClient(
      baseUrl: String.fromEnvironment('BETTER_AUTH_URL', defaultValue: 'http://localhost:3000'),
    );
  }

  @override
  void dispose() {
    authClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: authClient.getSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final response = snapshot.data!;
        if (response.isSuccess && response.data != null) {
          return HomePage(authClient: authClient, session: response.data!);
        }

        return LoginPage(authClient: authClient);
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  final BetterAuthClient authClient;

  const LoginPage({super.key, required this.authClient});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              autocorrect: false,
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : _signUp,
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await widget.authClient.signIn.email(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (response.isSuccess) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(
              authClient: widget.authClient,
              session: response.data!,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _error = response.error?.message ?? 'Sign in failed';
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await widget.authClient.signUp.email(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (response.isSuccess) {
      // After sign up, sign in
      await _signIn();
    } else {
      setState(() {
        _error = response.error?.message ?? 'Sign up failed';
        _isLoading = false;
      });
    }
  }
}

class HomePage extends StatefulWidget {
  final BetterAuthClient authClient;
  final Session session;

  const HomePage({super.key, required this.authClient, required this.session});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.session.user.name ?? widget.session.user.email}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.session.user.image != null)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.session.user.image!),
                radius: 48,
              ),
            const SizedBox(height: 16),
            Text(
              widget.session.user.name ?? 'User',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.session.user.email,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Session expires: ${widget.session.expiresAt.toLocal()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _viewSessions(context),
              icon: const Icon(Icons.devices),
              label: const Text('Manage Sessions'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await widget.authClient.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage(authClient: widget.authClient)),
      );
    }
  }

  Future<void> _viewSessions(BuildContext context) async {
    final response = await widget.authClient.session.list();
    if (response.isSuccess && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Active Sessions'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: response.data?.length ?? 0,
              itemBuilder: (context, index) {
                final s = response.data![index];
                return ListTile(
                  leading: Icon(
                    s.isCurrent ? Icons.computer : Icons.devices_other,
                    color: s.isCurrent ? Colors.green : null,
                  ),
                  title: Text(s.ipAddress ?? 'Unknown'),
                  subtitle: Text(
                    '${s.userAgent ?? 'Unknown device'}\nCreated: ${s.createdAt.toLocal()}',
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.authClient.session.revokeOthers();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Revoke Others'),
            ),
          ],
        ),
      );
    }
  }
}
