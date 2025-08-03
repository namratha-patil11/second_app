import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Dummy models
class ChatUser {
  final String id;
  final String name;
  final String avatarUrl;
  final String status;
  ChatUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime time;
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.time,
  });
}

// Hardcoded users and chats
final _dummyUsers = <ChatUser>[
  ChatUser(
    id: 'u1',
    name: 'Alice',
    avatarUrl: 'https://api.dicebear.com/7.x/personas/svg?seed=Alice',
    status: 'Hey there! I am using ChatApp.',
  ),
  ChatUser(
    id: 'u2',
    name: 'Bob',
    avatarUrl: 'https://api.dicebear.com/7.x/personas/svg?seed=Bob',
    status: 'Available',
  ),
  ChatUser(
    id: 'u3',
    name: 'Carol',
    avatarUrl: 'https://api.dicebear.com/7.x/personas/svg?seed=Carol',
    status: 'Busy',
  ),
];

final _dummyChats = [
  {
    'user': _dummyUsers[1],
    'lastMessage': 'See you at 5!',
    'time': DateTime.now().subtract(const Duration(minutes: 5)),
  },
  {
    'user': _dummyUsers[0],
    'lastMessage': 'How are you doing?',
    'time': DateTime.now().subtract(const Duration(hours: 2)),
  },
  {
    'user': _dummyUsers[2],
    'lastMessage': 'Let\'s catch up soon.',
    'time': DateTime.now().subtract(const Duration(days: 1, hours: 1)),
  },
];

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  String _getShortTime(DateTime dt) {
    final now = DateTime.now();
    if (now.day == dt.day && now.month == dt.month && now.year == dt.year) {
      // same day
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dt.month}/${dt.day}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats'), centerTitle: true),
      body: ListView.separated(
        itemCount: _dummyChats.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, idx) {
          final chat = _dummyChats[idx];
          final user = chat['user'] as ChatUser;
          final lastMsg = chat['lastMessage'] as String;
          final time = chat['time'] as DateTime;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatarUrl),
              radius: 28,
            ),
            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(_getShortTime(time), style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatScreen(peerUser: user),
              ));
            },
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final ChatUser peerUser;
  const ChatScreen({super.key, required this.peerUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
        id: 'm1',
        senderId: 'u1',
        text: 'Hello!',
        time: DateTime.now().subtract(const Duration(minutes: 10))),
    ChatMessage(
        id: 'm2',
        senderId: 'me',
        text: 'Hi Alice, how are you?',
        time: DateTime.now().subtract(const Duration(minutes: 8))),
    ChatMessage(
        id: 'm3',
        senderId: 'u1',
        text: 'Doing good, thanks. Ready to catch up at 5?',
        time: DateTime.now().subtract(const Duration(minutes: 5))),
  ];

  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me',
        text: _controller.text.trim(),
        time: DateTime.now(),
      ));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = (String id) => id == 'me';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(user: widget.peerUser),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.peerUser.avatarUrl),
                radius: 17,
              ),
            ),
            const SizedBox(width: 8),
            Text(widget.peerUser.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isMine = isMe(msg.senderId);
                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16).subtract(
                        BorderRadius.only(
                          bottomLeft: Radius.circular(isMine ? 16 : 0),
                          bottomRight: Radius.circular(isMine ? 0 : 16),
                        ),
                      ),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _handleSend,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final ChatUser user;
  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 54,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            const SizedBox(height: 22),
            Text(
              user.name,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(user.status, style: TextStyle(fontSize: 18, color: Colors.deepPurple.shade700)),
          ],
        ),
      ),
    );
  }
}
