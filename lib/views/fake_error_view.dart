import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/fake_error_viewmodel.dart';

class FakeErrorView extends StatelessWidget {
  const FakeErrorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FakeErrorViewModel()..startFakeError(),
      child: const _FakeErrorViewContent(),
    );
  }
}

class _FakeErrorViewContent extends StatelessWidget {
  const _FakeErrorViewContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FakeErrorViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        viewModel.close();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: viewModel.isTrollComplete 
              ? Colors.green
              : viewModel.loadingProgress % 0.2 < 0.1
                  ? Colors.red.withOpacity(0.8)
                  : Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    viewModel.isTrollComplete
                        ? Icons.check_circle
                        : Icons.error,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    viewModel.isTrollComplete
                        ? 'TROLLING COMPLETE 😎'
                        : 'Virus detected. Deleting files...',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  AnimatedOpacity(
                    opacity: viewModel.isTrollComplete ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: viewModel.loadingProgress,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          viewModel.isTrollComplete
                              ? Colors.green
                              : Colors.red,
                        ),
                        minHeight: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (viewModel.isTrollComplete)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 