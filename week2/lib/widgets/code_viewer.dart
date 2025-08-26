import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeViewer extends StatelessWidget {
  final String code;
  final bool showLineNumbers;

  const CodeViewer({
    super.key,
    required this.code,
    this.showLineNumbers = true,
  });

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.code,
                  size: 16,
                  color: Color(0xFF00FF41),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Code',
                  style: TextStyle(
                    color: Color(0xFF00FF41),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.grey,
                  ),
                  tooltip: 'Copy code',
                ),
              ],
            ),
          ),
          
          // Code content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line numbers
                  if (showLineNumbers) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        lines.length,
                        (index) => Container(
                          height: 20,
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: lines.length * 20.0,
                      color: Colors.grey[800],
                      margin: const EdgeInsets.only(right: 12),
                    ),
                  ],
                  
                  // Code text
                  Expanded(
                    child: SelectableText(
                      code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        backgroundColor: Color(0xFF00FF41),
        duration: Duration(seconds: 2),
      ),
    );
  }
}