import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {

  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(

        cursor: SystemMouseCursors.click,

        onEnter: (_) {
          setState(() {
            isHover = true;
          });
        },

        onExit: (_) {
          setState(() {
            isHover = false;
          });
        },

        child: AnimatedContainer(

          duration: const Duration(milliseconds: 200),

          transform: Matrix4.translationValues(
            0,
            isHover ? -4 : 0,
            0,
          ),

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(

            color: Colors.white,

            border: Border.all(
              color: isHover
                  ? const Color(0xFF08152E)
                  : Colors.grey.shade200,
            ),

            borderRadius: BorderRadius.circular(12),

            boxShadow: [

              BoxShadow(
                color: Colors.black.withOpacity(
                  isHover ? 0.10 : 0.03,
                ),
                blurRadius: isHover ? 16 : 6,
                offset: Offset(
                  0,
                  isHover ? 8 : 3,
                ),
              ),

            ],
          ),

          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF08152E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            widget.value,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
          ),
      ),
    );
  }
}