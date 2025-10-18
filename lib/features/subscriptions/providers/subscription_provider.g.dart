// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Subscription)
const subscriptionProvider = SubscriptionProvider._();

final class SubscriptionProvider
    extends $AsyncNotifierProvider<Subscription, SubscriptionInfo> {
  const SubscriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionHash();

  @$internal
  @override
  Subscription create() => Subscription();
}

String _$subscriptionHash() => r'5db22197bb01e89a48eefe349d211edc6ced005b';

abstract class _$Subscription extends $AsyncNotifier<SubscriptionInfo> {
  FutureOr<SubscriptionInfo> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<SubscriptionInfo>, SubscriptionInfo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SubscriptionInfo>, SubscriptionInfo>,
              AsyncValue<SubscriptionInfo>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
