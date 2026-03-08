import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'merchant_repo.dart';
import 'menu_repo.dart';
import 'order_repo.dart';
import 'payment_repo.dart';
import 'match_repo.dart';
import 'summary_repo.dart';

final merchantRepositoryProvider = Provider((ref) => MerchantRepository());
final menuRepositoryProvider = Provider((ref) => MenuRepository());
final orderRepositoryProvider = Provider((ref) => OrderRepository());
final paymentRepositoryProvider = Provider((ref) => PaymentRepository());
final matchRepositoryProvider = Provider((ref) => MatchRepository());
final summaryRepositoryProvider = Provider((ref) => SummaryRepository());