import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/common/resources/app_spacing.dart';
import 'package:scriptless/common/resources/app_typography.dart';
import 'package:scriptless/common/resources/image_resources.dart';
import 'package:scriptless/common/widgets/arrow_back_button.dart';
import 'package:scriptless/common/widgets/primary_button.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/app/presentation/bloc/app_bloc.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/persona_objective.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';
import 'package:scriptless/features/persona/presentation/cubit/persona_cubit.dart';
import 'package:scriptless/features/persona/presentation/cubit/persona_state.dart';
import 'package:scriptless/features/persona/presentation/widgets/rounded_check_box.dart';

/// Persona selection wizard screen.
///
/// Flow: Role -> Industry & Confidence -> Objectives.
/// Redirection: Permissions -> Dashboard.
class PersonaPage extends StatelessWidget {
  /// Creates the [PersonaPage].
  const PersonaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PersonaCubit>(
      create: (context) => sl<PersonaCubit>(),
      child: const _PersonaPageView(),
    );
  }
}

class _PersonaPageView extends StatefulWidget {
  const _PersonaPageView();

  @override
  State<_PersonaPageView> createState() => _PersonaPageViewState();
}

class _PersonaPageViewState extends State<_PersonaPageView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSuccess(BuildContext context) {
    final appState = context.read<AppBloc>().state;
    if (appState is AppNeedsPersona) {
      context.read<AppBloc>().add(AppPersonaCompleted(appState.user));
    }
    if (context.mounted) {
      context.go(AppRoutes.permissionsMicrophonePriming);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonaCubit, PersonaState>(
      listenWhen: (previous, current) =>
          previous.currentStep != current.currentStep ||
          previous.status != current.status,
      listener: (context, state) {
        if (_pageController.hasClients &&
            _pageController.page?.round() != state.currentStep) {
          _pageController.animateToPage(
            state.currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        if (state.status == PersonaStatus.success) {
          _onSuccess(context);
        } else if (state.status == PersonaStatus.failure &&
            state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<PersonaCubit>();
        final appState = context.watch<AppBloc>().state;
        final userId = appState is AppNeedsPersona
            ? appState.user.id
            : (appState is AppAuthenticated ? appState.user.id : '');

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.white,
            forceMaterialTransparency: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: state.currentStep > 0
                ? ArrowBackButton(
                    onPressed: cubit.previousStep,
                  )
                : null,
            // title: Text(
            //   'Étape ${state.currentStep + 1}/${state.totalSteps}',
            //   style: AppTypography.bodyMSemiBold.copyWith(
            //     color: AppColors.grey300,
            //   ),
            // ),
            // centerTitle: true,
          ),
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          extendBody: true,
          persistentFooterButtons: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: state.currentStep < state.totalSteps - 1
                  ? PrimaryButton(
                      key: const Key('persona_next_button'),
                      text: 'Continuer',
                      icon: SvgPicture.asset(
                        ImageResources.arrowRight,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        width: 20,
                      ),
                      iconAlignment: IconAlignment.end,
                      onPressed: state.canProceed ? cubit.nextStep : null,
                    )
                  : PrimaryButton(
                      key: const Key('persona_submit_button'),
                      text: 'Terminer',
                      isLoading: state.status == PersonaStatus.submitting,
                      onPressed: state.canProceed
                          ? () => cubit.submitPersona(userId)
                          : null,
                    ),
            ),
          ],
          body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
               if (didPop) {
          return;
        }
        if (state.currentStep > 0) {
          cubit.previousStep();
        } else {
          context.pop();
        }
            },
            child: Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 250, 206, 245),
                          Color.fromARGB(255, 238, 243, 253),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.05, 1.0],
                      ),
                    ),
                  ),
                ),
            
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        Text(
                          state.stepTitle,
                          style: AppTypography.headingH4SemiBold.copyWith(
                            color: AppColors.grey950,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing24),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _StepRoleView(
                                selectedRole: state.role,
                                onRoleSelected: cubit.selectRole,
                              ),
                              _StepIndustryConfidenceView(
                                selectedIndustry: state.industry,
                                confidenceLevel: state.confidenceLevel,
                                onIndustrySelected: cubit.selectIndustry,
                                onConfidenceChanged: cubit.setConfidenceLevel,
                              ),
                              _StepObjectivesView(
                                selectedObjectives: state.objectives,
                                onObjectiveToggled: cubit.toggleObjective,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StepRoleView extends StatelessWidget {
  const _StepRoleView({
    required this.selectedRole,
    required this.onRoleSelected,
  });

  final UserRole? selectedRole;
  final ValueChanged<UserRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: UserRole.values.map((role) {
        final isSelected = role == selectedRole;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 5,
              ),
              onTap: () => onRoleSelected(role),
              selected: isSelected,
              trailing: RoundedCheckBox(isSelected: isSelected),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.purpleHard : Colors.transparent,
                  width: isSelected ? 2 : 0,
                ),
              ),
              title: Text(
                role.label,
                style: AppTypography.bodyLSemiBold.copyWith(
                  color: AppColors.grey950,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StepIndustryConfidenceView extends StatelessWidget {
  const _StepIndustryConfidenceView({
    required this.selectedIndustry,
    required this.confidenceLevel,
    required this.onIndustrySelected,
    required this.onConfidenceChanged,
  });

  final Industry? selectedIndustry;
  final int confidenceLevel;
  final ValueChanged<Industry> onIndustrySelected;
  final ValueChanged<int> onConfidenceChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          "Secteur d'activité",
          style: AppTypography.bodyMSemiBold.copyWith(color: AppColors.grey300),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Industry.values.map((industry) {
            final isSelected = industry == selectedIndustry;
            return ChoiceChip(
              label: Text(industry.label),
              selected: isSelected,
              onSelected: (_) => onIndustrySelected(industry),
              selectedColor: AppColors.purpleHard,
              backgroundColor: AppColors.grey900,
              labelStyle: AppTypography.bodySRegular.copyWith(
                color: isSelected ? AppColors.white : AppColors.grey300,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        Text(
          "Niveau d'aisance (1 à 10) : $confidenceLevel",
          style: AppTypography.bodyMSemiBold.copyWith(color: AppColors.grey300),
        ),
        Slider(
          value: confidenceLevel.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: AppColors.purpleHard,
          inactiveColor: AppColors.grey800,
          onChanged: (val) => onConfidenceChanged(val.round()),
        ),
      ],
    );
  }
}

class _StepObjectivesView extends StatelessWidget {
  const _StepObjectivesView({
    required this.selectedObjectives,
    required this.onObjectiveToggled,
  });

  final List<String> selectedObjectives;
  final ValueChanged<String> onObjectiveToggled;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: PersonaObjective.defaultObjectives.map((objective) {
        final isSelected = selectedObjectives.contains(objective);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onObjectiveToggled(objective),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.purpleHard.withValues(alpha: 0.15)
                    : AppColors.grey900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.purpleHard : AppColors.grey800,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      objective,
                      style: AppTypography.bodyMMedium.copyWith(
                        color: isSelected ? AppColors.white : AppColors.grey300,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected
                        ? AppColors.purpleHard
                        : AppColors.grey500,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
