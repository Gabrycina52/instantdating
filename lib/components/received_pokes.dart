import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_dating/components/gradient_opacity.dart';
import 'package:instant_dating/screens/VisitedUserScreen/visited_user_screen.dart';
import 'package:instant_dating/services/size_config.dart';
import 'package:instant_dating/screens/PokesScreen/components/SwipeAnimation/swipe_card.dart';

final _firestore = Firestore.instance;

class ReceivedPokes extends StatefulWidget {
  ReceivedPokes({this.accountName});

  final String accountName;

  @override
  _ReceivedPokesState createState() => _ReceivedPokesState();
}

class _ReceivedPokesState extends State<ReceivedPokes> {
  int removeFromListIndex = 0;
  var val = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('devicesLocation')
          .document(widget.accountName)
          .collection('pokes')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.purple[100],
            ),
          );

        final receivedPokes = snapshot.data.documents;
        List<dynamic> usersDocsDecoded = [];

        for (var receivedPoke in receivedPokes) {
          if (receivedPoke.documentID != 'receivedCounter') {
            var now = DateTime.now();
            Timestamp pokeSentAtTimestamp = receivedPoke.data['time'];

            //Converts Timestamp to DateTime and then calculates the difference
            DateTime pokeSentAtDateTime = DateTime.fromMillisecondsSinceEpoch(
                pokeSentAtTimestamp.millisecondsSinceEpoch);
            var diff = now.difference(pokeSentAtDateTime);
            if (diff.inMinutes <= 15) {
              var senderEmail = receivedPoke.data['sender'];
//            var senderLatitude = receivedPoke.data['position'].latitude;
//            var senderLongitude = receivedPoke.data['position'].longitude;
              var senderImage = receivedPoke.data['image'];
              usersDocsDecoded.add(
                Stack(
                  children: <Widget>[
                    Container(
                      height: SizeConfig.vertical * 68,
                      width: SizeConfig.horizontal * 78,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          //image
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.horizontal * 1,
                                vertical: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: senderImage,
                                imageBuilder: (context, imageProvider) {
                                  return Hero(
                                    tag: senderEmail,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.horizontal * 1,
                                vertical: 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (cxt) => VisitedUser(
                                      userImage: senderImage,
                                      //change with name and surname
                                      userEmail: senderEmail,
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'opacity$senderImage',
                                child: GradientOpacity(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Christian, 19',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConfig.horizontal * 5,
                                  ),
                                ),
                                Text(
                                  'Palermo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConfig.horizontal * 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              val++;
            }
          } else {
            removeFromListIndex++;
          }
        }

        if (usersDocsDecoded.length > 0) {
          return Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text('Hai finito tutti i tuoi poke!'),
              ),
              SwipeCard(
                data: usersDocsDecoded,
              ),
            ],
          );
        } else {
          return Center(
            child: Text('Nessun Poke ricevuto negli ultimi 15 minuti'),
          );
        }
      },
    );
  }
}
