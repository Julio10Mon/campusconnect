import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/user_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/user_management_providers.dart';
import '../../../widgets/logo_app.dart';
import '../../../widgets/screen_header.dart';
import '../../../widgets/state_placeholders.dart';
import '../../../widgets/user_admin_card.dart';
import 'user_edit_screen.dart';

/// Panel admin usuarios
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<UserModel> _filter(List<UserModel> users, UserRole rol) {
    final q = _query.trim().toLowerCase();
    return users.where((u) {
      if (u.rol != rol) return false;
      if (q.isEmpty) return true;
      return u.nombre.toLowerCase().contains(q) || u.correo.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersStreamProvider);
    final currentUid = ref.read(firebaseAuthProvider).currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(8), child: LogoApp(size: 32)),
        title: const ScreenHeaderTitle(eyebrow: AppStrings.appName, title: 'Administración de usuarios'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Administradores'),
            Tab(text: 'Estudiantes'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o correo…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          _searchCtrl.clear();
                          _query = '';
                        }),
                      ),
              ),
            ),
          ),
          Expanded(
            child: usersAsync.when(
              loading: () => const LoadingState(),
              error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(allUsersStreamProvider)),
              data: (users) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _UserList(users: _filter(users, UserRole.admin), currentUid: currentUid, emptyMessage: 'No hay administradores que coincidan con la búsqueda.'),
                    _UserList(users: _filter(users, UserRole.estudiante), currentUid: currentUid, emptyMessage: 'No hay estudiantes que coincidan con la búsqueda.'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserList extends ConsumerWidget {
  final List<UserModel> users;
  final String? currentUid;
  final String emptyMessage;

  const _UserList({required this.users, required this.currentUid, required this.emptyMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (users.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: EmptyState(message: emptyMessage, icon: Icons.people_outline),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24, top: 4),
      itemCount: users.length,
      itemBuilder: (context, i) {
        final user = users[i];
        final isSelf = user.uid == currentUid;
        return UserAdminCard(
          user: user,
          isSelf: isSelf,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => UserEditScreen(user: user, isSelf: isSelf)),
          ),
          onToggleActive: (value) => ref.read(userAdminControllerProvider.notifier).setActive(user.uid, value),
        );
      },
    );
  }
}
