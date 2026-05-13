import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/auth/welcome_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/otp_screen.dart';
import '../presentation/screens/home/main_scaffold.dart';
import '../presentation/screens/categories/categories_screen.dart';
import '../presentation/screens/search/search_results_screen.dart';
import '../presentation/screens/provider_profile/provider_profile_screen.dart';
import '../presentation/screens/messages/chat_screen.dart';
import '../presentation/screens/booking/booking_screen.dart';
import '../presentation/screens/profile/bookings_screen.dart';
import '../presentation/screens/profile/favorites_screen.dart';
import '../presentation/screens/profile/edit_profile_screen.dart';
import '../presentation/screens/provider/provider_register_screen.dart';
import '../presentation/screens/provider/identity_verification_screen.dart';
import '../presentation/screens/provider/provider_contract_screen.dart';
import '../presentation/screens/provider/provider_dashboard_screen.dart';
import '../presentation/screens/provider/provider_requests_screen.dart';
import '../presentation/screens/provider/provider_wallet_screen.dart';
import '../presentation/screens/provider/provider_loyalty_screen.dart';
import '../presentation/screens/provider/provider_messages_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp/:phone';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String searchResults = '/search';
  static const String providerProfile = '/provider/:id';
  static const String chat = '/chat/:conversationId';
  static const String booking = '/booking/:providerId';
  static const String myBookings = '/bookings';
  static const String favorites = '/favorites';
  static const String editProfile = '/edit-profile';
  static const String providerRegister = '/provider-register';
  static const String identityVerification = '/identity-verification';
  static const String providerContract = '/provider-contract';
  static const String providerDashboard = '/provider-dashboard';
  static const String providerRequests = '/provider-requests';
  static const String providerWallet = '/provider-wallet';
  static const String providerLoyalty = '/provider-loyalty';
  static const String providerMessages = '/provider-messages';

  static GoRouter router(BuildContext context) {
    return GoRouter(
      initialLocation: splash,
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        final isAuth = auth.isAuthenticated;
        final loc = state.matchedLocation;
        final onSplash = loc == splash;
        final onOnboarding = loc == onboarding;
        final onAuth = loc == login ||
            loc == register ||
            loc == welcome ||
            loc.startsWith('/otp');
        final onProviderOnboarding = loc == providerRegister ||
            loc == identityVerification ||
            loc == providerContract;

        if (onSplash || onOnboarding || onAuth || onProviderOnboarding) {
          return null;
        }
        if (!isAuth) return welcome;
        return null;
      },
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/otp/:phone',
          builder: (context, state) {
            final phone = state.pathParameters['phone']!;
            final destination = state.uri.queryParameters['dest'] ?? '/home';
            return OtpScreen(phone: phone, destination: destination);
          },
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: home,
          builder: (context, state) => const MainScaffold(),
          routes: [
            GoRoute(
              path: 'categories',
              builder: (context, state) {
                final group = state.uri.queryParameters['group'];
                return CategoriesScreen(selectedGroup: group);
              },
            ),
          ],
        ),
        GoRoute(
          path: categories,
          builder: (context, state) {
            final group = state.uri.queryParameters['group'];
            return CategoriesScreen(selectedGroup: group);
          },
        ),
        GoRoute(
          path: searchResults,
          builder: (context, state) {
            final query = state.uri.queryParameters['q'] ?? '';
            final categoryGroup = state.uri.queryParameters['category'];
            return SearchResultsScreen(
              initialQuery: query,
              categoryGroup: categoryGroup,
            );
          },
        ),
        GoRoute(
          path: providerProfile,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProviderProfileScreen(providerId: id);
          },
        ),
        GoRoute(
          path: chat,
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            return ChatScreen(conversationId: conversationId);
          },
        ),
        GoRoute(
          path: booking,
          builder: (context, state) {
            final providerId = state.pathParameters['providerId']!;
            return BookingScreen(providerId: providerId);
          },
        ),
        GoRoute(
          path: myBookings,
          builder: (context, state) => const BookingsScreen(),
        ),
        GoRoute(
          path: favorites,
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),

        // Provider onboarding
        GoRoute(
          path: providerRegister,
          builder: (context, state) => const ProviderRegisterScreen(),
        ),
        GoRoute(
          path: identityVerification,
          builder: (context, state) => const IdentityVerificationScreen(),
        ),
        GoRoute(
          path: providerContract,
          builder: (context, state) => const ProviderContractScreen(),
        ),

        // Provider dashboard area
        GoRoute(
          path: providerDashboard,
          builder: (context, state) => const ProviderDashboardScreen(),
        ),
        GoRoute(
          path: providerRequests,
          builder: (context, state) => const ProviderRequestsScreen(),
        ),
        GoRoute(
          path: providerWallet,
          builder: (context, state) => const ProviderWalletScreen(),
        ),
        GoRoute(
          path: providerLoyalty,
          builder: (context, state) => const ProviderLoyaltyScreen(),
        ),
        GoRoute(
          path: providerMessages,
          builder: (context, state) => const ProviderMessagesScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page non trouvée: ${state.error}'),
        ),
      ),
    );
  }
}
