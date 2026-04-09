import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String counterpartName;
  final String itemName;

  const ChatDetailScreen({
    super.key,
    required this.counterpartName,
    required this.itemName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  
  // 더미 메시지 데이터
  final List<Map<String, dynamic>> _messages = [
    {'text': '안녕하세요, 올리신 검정 가죽 지갑 제 것 같습니다!', 'isMe': true, 'time': '오후 8:30'},
    {'text': '아 네! 안에 어떤 신분증이 들어있나요?', 'isMe': false, 'time': '오후 8:31'},
    {'text': '홍길동 이름으로 된 운전면허증이 있습니다.', 'isMe': true, 'time': '오후 8:33'},
    {'text': '네 맞네요. 어디서 전해드릴까요?', 'isMe': false, 'time': '오후 8:35'},
    {'text': '내일 강남역 어떠신가요?', 'isMe': true, 'time': '오후 8:40'},
    {'text': '네, 내일 오후 2시에 강남역 3번 출구에서 뵐게요.', 'isMe': false, 'time': '오후 8:43'},
  ];

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'text': _msgController.text.trim(),
        'isMe': true,
        'time': '방금 전', // 실제 앱에서는 DateTime 포맷팅
      });
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.counterpartName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.itemName, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // 매칭 정보 상단 배너
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('개인정보 보호를 위해 연락처 교환에 주의해주세요.', style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ],
            ),
          ),
          
          // 채팅 내역 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMe) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (isMe)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                          child: Text(msg['time'] as String, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF2563EB) : Colors.white,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                              bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(16),
                            ),
                            border: isMe ? null : Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            msg['text'] as String,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                      if (!isMe)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                          child: Text(msg['time'] as String, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // 입력창
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.grey),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF2563EB),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
