import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/bolo_button.dart';
import '../../widgets/bolo_logo.dart';
import '../../widgets/bolo_text_field.dart';

class ProviderRegisterScreen extends StatefulWidget {
  const ProviderRegisterScreen({super.key});

  @override
  State<ProviderRegisterScreen> createState() =>
      _ProviderRegisterScreenState();
}

class _ProviderRegisterScreenState extends State<ProviderRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  bool _isLoading = false;
  File? _profilePhoto;

  // Step 1 — Infos personnelles
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedCountry = 'Cameroun';
  final _cityCtrl = TextEditingController();

  // Step 2 — Profil professionnel
  final _metierCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _experience = 1;
  int _pricePerHour = 5000;
  String _selectedCategory = 'Personnel de maison';

  // Step 3 — Disponibilités
  final Map<String, bool> _days = {
    'Lundi': true, 'Mardi': true, 'Mercredi': true,
    'Jeudi': true, 'Vendredi': true, 'Samedi': false, 'Dimanche': false,
  };
  String _startTime = '08:00';
  String _endTime = '18:00';

  static const _countries = [
    'Cameroun', 'Côte d\'Ivoire', 'Sénégal', 'Mali',
    'Burkina Faso', 'Niger', 'Guinée', 'Gabon', 'Congo',
  ];

  static const _categories = [
    'Personnel de maison', 'Personnel événementiel',
    'Assistance handicap/âgés', 'Digital', 'Mode et beauté',
    'Transport et logistique', 'Autres services',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _metierCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _profilePhoto = File(picked.path));
    }
  }

  void _nextStep() {
    if (_step == 0) {
      if (_nameCtrl.text.trim().isEmpty ||
          _phoneCtrl.text.trim().isEmpty ||
          _cityCtrl.text.trim().isEmpty) {
        _snack('Veuillez remplir tous les champs obligatoires');
        return;
      }
    } else if (_step == 1) {
      if (_metierCtrl.text.trim().isEmpty ||
          _descCtrl.text.trim().length < 20) {
        _snack('Décrivez votre métier (au moins 20 caractères)');
        return;
      }
    }
    setState(() => _step++);
  }

  Future<void> _submit() async {
    final selected = _days.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selected.isEmpty) {
      _snack('Sélectionnez au moins un jour de disponibilité');
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go('/identity-verification');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _step == 0 ? () => context.pop() : () => setState(() => _step--),
        ),
        title: const BoloLogo(size: 36),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Stepper indicator
          _StepIndicator(currentStep: _step, totalSteps: 3),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0
                      ? _StepPersonal(
                          key: const ValueKey(0),
                          nameCtrl: _nameCtrl,
                          phoneCtrl: _phoneCtrl,
                          cityCtrl: _cityCtrl,
                          selectedCountry: _selectedCountry,
                          countries: _countries,
                          profilePhoto: _profilePhoto,
                          onPickPhoto: _pickPhoto,
                          onCountryChanged: (v) =>
                              setState(() => _selectedCountry = v!),
                        )
                      : _step == 1
                          ? _StepProfessional(
                              key: const ValueKey(1),
                              metierCtrl: _metierCtrl,
                              descCtrl: _descCtrl,
                              experience: _experience,
                              pricePerHour: _pricePerHour,
                              selectedCategory: _selectedCategory,
                              categories: _categories,
                              onExperienceChanged: (v) =>
                                  setState(() => _experience = v),
                              onPriceChanged: (v) =>
                                  setState(() => _pricePerHour = v),
                              onCategoryChanged: (v) =>
                                  setState(() => _selectedCategory = v!),
                            )
                          : _StepAvailability(
                              key: const ValueKey(2),
                              days: _days,
                              startTime: _startTime,
                              endTime: _endTime,
                              onDayToggled: (day, val) =>
                                  setState(() => _days[day] = val),
                              onStartChanged: (v) =>
                                  setState(() => _startTime = v),
                              onEndChanged: (v) =>
                                  setState(() => _endTime = v),
                            ),
                ),
              ),
            ),
          ),

          // Bouton
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 0, 24, MediaQuery.of(context).padding.bottom + 16),
            child: BoloButton(
              onPressed: _step < 2 ? _nextStep : _submit,
              label: _step < 2 ? 'Continuer' : 'Soumettre mon profil',
              isLoading: _isLoading,
              icon: _step < 2
                  ? Icons.arrow_forward_rounded
                  : Icons.check_circle_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1 : Infos personnelles ─────────────────────────────────────────────

class _StepPersonal extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController cityCtrl;
  final String selectedCountry;
  final List<String> countries;
  final File? profilePhoto;
  final VoidCallback onPickPhoto;
  final ValueChanged<String?> onCountryChanged;

  const _StepPersonal({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.cityCtrl,
    required this.selectedCountry,
    required this.countries,
    required this.profilePhoto,
    required this.onPickPhoto,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Votre profil', style: AppTextStyles.headlineLarge),
        const SizedBox(height: 4),
        Text('Informations qui seront visibles par les clients.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        // Photo de profil
        Center(
          child: GestureDetector(
            onTap: onPickPhoto,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3), width: 2),
                    image: profilePhoto != null
                        ? DecorationImage(
                            image: FileImage(profilePhoto!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profilePhoto == null
                      ? const Icon(Icons.person_rounded,
                          size: 48, color: AppColors.primary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text('Ajouter une photo *',
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
        ),
        const SizedBox(height: 24),

        BoloTextField(
          controller: nameCtrl,
          label: 'Nom complet *',
          hint: 'Jean Kameni',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),
        BoloTextField(
          controller: phoneCtrl,
          label: 'Téléphone *',
          hint: '+237 6XX XXX XXX',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
        const SizedBox(height: 14),

        // Pays
        Text('Pays *', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCountry,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.flag_outlined,
                color: AppColors.textLight),
          ),
          items: countries
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onCountryChanged,
        ),
        const SizedBox(height: 14),

        BoloTextField(
          controller: cityCtrl,
          label: 'Ville *',
          hint: 'Yaoundé, Douala...',
          prefixIcon: Icons.location_city_rounded,
        ),
      ],
    );
  }
}

// ─── Step 2 : Profil professionnel ───────────────────────────────────────────

class _StepProfessional extends StatelessWidget {
  final TextEditingController metierCtrl;
  final TextEditingController descCtrl;
  final int experience;
  final int pricePerHour;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<int> onExperienceChanged;
  final ValueChanged<int> onPriceChanged;
  final ValueChanged<String?> onCategoryChanged;

  const _StepProfessional({
    super.key,
    required this.metierCtrl,
    required this.descCtrl,
    required this.experience,
    required this.pricePerHour,
    required this.selectedCategory,
    required this.categories,
    required this.onExperienceChanged,
    required this.onPriceChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Votre métier', style: AppTextStyles.headlineLarge),
        const SizedBox(height: 4),
        Text('Ces informations aident les clients à vous trouver.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        // Catégorie
        Text('Catégorie *', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.category_outlined,
                color: AppColors.textLight),
          ),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onCategoryChanged,
        ),
        const SizedBox(height: 14),

        BoloTextField(
          controller: metierCtrl,
          label: 'Intitulé du métier *',
          hint: 'Ex: Femme de ménage, Cuisinier, Photographe...',
          prefixIcon: Icons.work_outline_rounded,
        ),
        const SizedBox(height: 14),

        Text('Description / Bio *', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: descCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                'Décrivez vos compétences, votre expérience et ce qui vous distingue...',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 20),

        // Expérience
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Années d\'expérience', style: AppTextStyles.titleSmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$experience an${experience > 1 ? 's' : ''}',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        Slider(
          value: experience.toDouble(),
          min: 1,
          max: 30,
          divisions: 29,
          activeColor: AppColors.primary,
          onChanged: (v) => onExperienceChanged(v.toInt()),
        ),
        const SizedBox(height: 12),

        // Tarif
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tarif horaire (FCFA/h)', style: AppTextStyles.titleSmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$pricePerHour FCFA',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        Slider(
          value: pricePerHour.toDouble(),
          min: 1000,
          max: 100000,
          divisions: 99,
          activeColor: AppColors.primary,
          onChanged: (v) => onPriceChanged((v / 1000).round() * 1000),
        ),
      ],
    );
  }
}

// ─── Step 3 : Disponibilités ─────────────────────────────────────────────────

class _StepAvailability extends StatelessWidget {
  final Map<String, bool> days;
  final String startTime;
  final String endTime;
  final void Function(String, bool) onDayToggled;
  final ValueChanged<String> onStartChanged;
  final ValueChanged<String> onEndChanged;

  const _StepAvailability({
    super.key,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.onDayToggled,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  static const _times = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vos disponibilités', style: AppTextStyles.headlineLarge),
        const SizedBox(height: 4),
        Text('Les clients verront quand vous êtes disponible.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        Text('Jours disponibles *', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days.entries.map((entry) {
            final active = entry.value;
            return GestureDetector(
              onTap: () => onDayToggled(entry.key, !active),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  entry.key.substring(0, 3),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: active ? Colors.white : AppColors.textSecondary,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        Text('Horaires de travail', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TimeDropdown(
                label: 'Début',
                value: startTime,
                times: _times,
                onChanged: onStartChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeDropdown(
                label: 'Fin',
                value: endTime,
                times: _times,
                onChanged: onEndChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Après soumission, votre dossier sera examiné par BOLO. Vous recevrez un email de confirmation sous 24h.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> times;
  final ValueChanged<String> onChanged;

  const _TimeDropdown({
    required this.label,
    required this.value,
    required this.times,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: times
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }
}

// ─── Stepper indicator ────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  static const _labels = ['Profil', 'Métier', 'Disponibilités'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: List.generate(totalSteps, (i) {
              final done = i < currentStep;
              final active = i == currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: done || active
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (i < totalSteps - 1) const SizedBox(width: 4),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (i) {
              final active = i == currentStep;
              final done = i < currentStep;
              return Text(
                _labels[i],
                style: AppTextStyles.caption.copyWith(
                  color: done || active
                      ? AppColors.primary
                      : AppColors.textLight,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w400,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
