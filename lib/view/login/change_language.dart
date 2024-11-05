import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_app/common/color_extension.dart';
import 'package:transport_app/view/login/welcome_view.dart';

import '../../common/appLocalizations .dart';
import '../../cubit/change_language/language_cubit.dart';

class ChangeLanguageView extends StatefulWidget {

  final Function(String languageCode) changeLanguage;
  final bool closing;

  const ChangeLanguageView({super.key, required this.changeLanguage, required this.closing});

  @override
  State<ChangeLanguageView> createState() => _ChangeLanguageViewState();
}

class _ChangeLanguageViewState extends State<ChangeLanguageView> {

  List listArr = [
    "Español",
    "English"
  ];

  int selectChange = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            context.pop();
          },
          icon: Image.asset("assets/images/back.png",
            width: 20,
            height: 20, 
          ),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(AppLocalizations.of(context).translate('choose_language'),
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 25,
              fontWeight: FontWeight.w800            
              ),
            ),

            const SizedBox(height: 15,),

            Expanded(
              child: ListView.builder(
                itemCount: listArr.length,
                itemBuilder: (context,index){
                  return ListTile(
                    onTap: (){
                      if(widget.closing){
                        if(index==0){
                          BlocProvider.of<LanguageCubit>(context).changeLanguage("es");
                        }else
                        if(index==1){
                          BlocProvider.of<LanguageCubit>(context).changeLanguage("en");
                        }
                        context.pop();
                      }else{
                        if(index==0){
                          widget.changeLanguage("es");
                        }else
                        if(index==1){
                          widget.changeLanguage("en");
                        }

                        setState(() {
                          selectChange = index;
                        });
                        context.push(WelcomeView());
                      }
                    },
                    title: Text(
                      listArr[index],
                      style: TextStyle(
                          color: index == selectChange ? 
                          TColor.primary :
                          TColor.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800 
                        ),
                    ),
                    trailing: index == selectChange ? 
                      Image.asset("assets/images/check_tick.png",width: 25) : 
                      null,
                  );
                }
              )
            )
          ],
        ),
      ),
    );
  }
}