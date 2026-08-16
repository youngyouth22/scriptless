import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scriptless/app.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/app/presentation/bloc/app_bloc.dart';
import 'package:scriptless/features/subscription/data/datasources/revenuecat_remote_datasource.dart';
import 'package:scriptless/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:scriptless/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:scriptless/flavors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provided by flutter_flavorizr via --dart-define=appFlavor=<flavor>
const String appFlavor = String.fromEnvironment('appFlavor');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
  );

  // Load environment variables based on flavor
  final envFile = '.env.${F.appFlavor.name}';
  await dotenv.load(fileName: envFile);

  // Initialize Supabase client
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Register all dependencies (must run after Supabase.initialize)
  await configureDependencies();

  // Initialize RevenueCat SDK
  final revenueCatApiKey = dotenv.env['REVENUECAT_API_KEY'];
  if (revenueCatApiKey != null && revenueCatApiKey.isNotEmpty) {
    await sl<RevenueCatRemoteDataSource>().initialize(revenueCatApiKey);
  }

  // Start global session check and subscription status fetch
  sl<AppBloc>().add(const AppStarted());
  sl<SubscriptionBloc>().add(const SubscriptionCheckRequested());

  runApp(const App());
}
