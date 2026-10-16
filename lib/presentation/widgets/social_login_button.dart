import 'package:flutter/material.dart';

/// Botón login social
class SocialLoginButton extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String? iconAsset;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    this.icon,
    this.iconColor,
    this.iconAsset,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  }) : assert(icon != null || iconAsset != null, 'Provee icon o iconAsset.');

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          else if (iconAsset != null)
            Image.asset(
              iconAsset!,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              // Ícono de respaldo
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, size: 20),
            )
          else
            Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
