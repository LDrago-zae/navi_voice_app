// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../controllers/voice_controller.dart';
// import '../../models/voice_model.dart';

// class VoiceSelector extends StatelessWidget {
//   final void Function(VoiceModel)? onVoiceSelected;
//   final bool showAsDialog;

//   const VoiceSelector({
//     Key? key,
//     this.onVoiceSelected,
//     this.showAsDialog = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<VoiceController>(
//       builder: (context, controller, child) {
//         if (controller.loading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (controller.error != null) {
//           return Center(child: Text('Error: ${controller.error}'));
//         }
//         if (controller.voices.isEmpty) {
//           return const Center(child: Text('No voices available.'));
//         }
//         return ListView.separated(
//           shrinkWrap: true,
//           itemCount: controller.voices.length,
//           separatorBuilder: (_, __) => const Divider(height: 1),
//           itemBuilder: (context, index) {
//             final voice = controller.voices[index];
//             final isSelected = controller.selectedVoice?.id == voice.id;
//             return ListTile(
//               title: Text(voice.name),
//               subtitle: voice.description != null
//                   ? Text(voice.description!)
//                   : null,
//               trailing: isSelected
//                   ? const Icon(Icons.check_circle, color: Colors.green)
//                   : null,
//               onTap: () {
//                 controller.selectVoice(voice);
//                 if (onVoiceSelected != null) onVoiceSelected!(voice);
//                 if (showAsDialog) Navigator.of(context).pop();
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
