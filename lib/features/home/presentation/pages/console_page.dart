import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_vmaf/core/utils/logger.dart';

class ConsolePage extends StatefulWidget {
  const ConsolePage({super.key});

  @override
  State<ConsolePage> createState() => _ConsolePageState();
}

class _ConsolePageState extends State<ConsolePage> {
  final _scrollController = ScrollController();
  final _logLines = <String>[];
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    _logLines.addAll(Logger.logs);
    _subscription = Logger.stream.listen((log) {
      if (mounted) {
        setState(() {
          _logLines.add(log);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'Console',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _clearLog,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: _logLines.isEmpty
                  ? Center(
                      child: Text(
                        'No logs yet...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _logLines.length,
                      itemBuilder: (context, index) {
                        return Text(
                          _logLines[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearLog() async {
    await Logger.clearLog();
    setState(() {
      _logLines.clear();
    });
  }
}