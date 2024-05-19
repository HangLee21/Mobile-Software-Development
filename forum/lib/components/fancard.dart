import 'package:flutter/material.dart';

class FanCard extends StatelessWidget{
  final String userAvatar;
  final String userName;
  final void Function() deletePerson;
  @override
  FanCard(this.userAvatar, this.userName, this.deletePerson);
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 90,
      child: Card(
          child: Row(

            children: [
              const SizedBox(
                  width:10
              ),
              Row(
                children: [
                  CircleAvatar(
                    foregroundImage: NetworkImage(userAvatar),
                    backgroundImage: NetworkImage('https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar_1.png'),
                    radius: 30,
                  ),
                  const SizedBox(
                      width:20
                  ),
                  Text(
                      userName,
                      style:const TextStyle(
                        fontSize: 18,
                      )
                  )
                ],
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  deletePerson();
                },
                icon: Icon(
                    Icons.person_off,
                    size: 27,
                ),
              ),
              const SizedBox(width: 10,)
            ],
          )

      ),
    );
  }
}