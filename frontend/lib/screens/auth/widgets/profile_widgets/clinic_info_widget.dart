import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import 'detail_row_widget.dart';

class ClinicInfoWidget extends StatelessWidget {
  final List<ClinicInfo> clinics;

  const ClinicInfoWidget({super.key, required this.clinics});

  @override
  Widget build(BuildContext context) {
    if (clinics.isEmpty) {
      return DetailRowWidget(label: 'Clínicas', value: 'No asignadas');
    }

    return Column(
      children: List.generate(clinics.length, (index) {
        final clinic = clinics[index];
        final widgets = <Widget>[
          DetailRowWidget(
            label: index == 0 ? 'Clínica' : 'Clínica ${index + 1}',
            value: clinic.name,
          ),
        ];

        if (clinic.officeNumber != null && clinic.officeNumber!.isNotEmpty) {
          widgets.add(
            DetailRowWidget(label: 'Consultorio', value: clinic.officeNumber!),
          );
        }

        widgets.add(DetailRowWidget(label: 'Dirección', value: clinic.address));

        if (index < clinics.length - 1) {
          widgets.add(const SizedBox(height: 10));
        }

        return Column(children: widgets);
      }),
    );
  }
}
