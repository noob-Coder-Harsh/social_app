import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? function;
  final String text;
  final Image? imageName;


  const MyButton({
    super.key,
    required this.function,
    required this.text,
    this.imageName,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
        function!.call();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black,
        ),
        child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imageName ?? Image.asset('assets/dot.png',width: 5,height: 5,),
                const SizedBox(width: 10,),
                Text(text,
                          style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
              ],
            )),
      ),
    );
  }
}
