import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Align(
        alignment: isUser
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width * .8,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (isUser)

                SelectableText(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                )

              else

                MarkdownBody(

                  selectable: true,

                  data: message.text,

                  onTapLink:
                      (text, href, title) async {

                    if (href == null) return;

                    final uri = Uri.parse(href);

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }

                  },

                  styleSheet:
                      MarkdownStyleSheet(

                    p: const TextStyle(
                      fontSize: 16,
                    ),

                    h1: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),

                    h2: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),

                    h3: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),

                    code: const TextStyle(
                      fontFamily: 'monospace',
                      backgroundColor:
                          Color(0xffeeeeee),
                    ),

                    blockquote: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: () {

                    Clipboard.setData(
                      ClipboardData(
                        text: message.text,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content:
                            Text("Copied"),
                      ),
                    );

                  },
                  child: Icon(
                    Icons.copy,
                    size: 18,
                    color: isUser
                        ? Colors.white70
                        : Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}