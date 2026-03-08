import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cash_entry/cash_entry_provider.dart';
import '../evidence/evidence_provider.dart';
import '../review/recap_draft_provider.dart';
import '../selling/selling_provider.dart';

enum DayFlowState {
  initial,
  evidenceUploaded,
  readyToReview,
  confirmed,
}

@immutable
class HomeState {
  final double totalSales;
  final double digitalTotal;
  final double cashTotal;
  final int unresolvedMatches;
  final DayFlowState flowState;

  const HomeState({
    this.totalSales = 0,
    this.digitalTotal = 0,
    this.cashTotal = 0,
    this.unresolvedMatches = 0,
    this.flowState = DayFlowState.initial,
  });

  HomeState copyWith({
    double? totalSales,
    double? digitalTotal,
    double? cashTotal,
    int? unresolvedMatches,
    DayFlowState? flowState,
  }) {
    return HomeState(
      totalSales: totalSales ?? this.totalSales,
      digitalTotal: digitalTotal ?? this.digitalTotal,
      cashTotal: cashTotal ?? this.cashTotal,
      unresolvedMatches: unresolvedMatches ?? this.unresolvedMatches,
      flowState: flowState ?? this.flowState,
    );
  }
}

final homeProvider = Provider<HomeState>((ref) {
  final evidenceState = ref.watch(evidenceProvider);
  final sellingState = ref.watch(sellingProvider);
  final cashState = ref.watch(cashEntryProvider);
  final recapDraft = ref.watch(recapDraftProvider);

  final digitalTotal = evidenceState.resultById.values
      .expand((result) => result.amounts)
      .fold<double>(0, (sum, amount) => sum + amount.amount);
  final cashTotal = cashState.amount ?? 0;
  final fallbackSellingTotal = sellingState.estimatedTotal;
  final totalSales = (digitalTotal > 0 ? digitalTotal : fallbackSellingTotal) + cashTotal;
  final unresolvedMatches = evidenceState.statusById.values.where((status) => status == EvidenceProcessingStatus.error).length;

  final hasActivity = evidenceState.files.isNotEmpty || sellingState.totalTaps > 0 || cashTotal > 0 || recapDraft.isTranscriptConfirmed;
  final flowState = cashState.isConfirmed
      ? DayFlowState.readyToReview
      : hasActivity
          ? DayFlowState.evidenceUploaded
          : DayFlowState.initial;

  return HomeState(
    totalSales: totalSales,
    digitalTotal: digitalTotal,
    cashTotal: cashTotal,
    unresolvedMatches: unresolvedMatches,
    flowState: flowState,
  );
});
