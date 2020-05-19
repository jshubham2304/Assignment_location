import 'package:google_maps_flutter/google_maps_flutter.dart';

class SpeedTimeCriteria{
    SpeedTimeCriteria();
     getColor(int speed)  {
   if(speed >=0 && speed <= 20)
   {
     var hueAzure = BitmapDescriptor.hueAzure;
     return hueAzure;
   }
   else if(speed >20 && speed<=30)
   {
     return BitmapDescriptor.hueBlue;
   }
   else if(speed>=30 && speed<=50)
   {
   return BitmapDescriptor.hueCyan;
     
   }else if(speed>=50 && speed<=80)
   {
   return BitmapDescriptor.hueGreen;
     
   }else if(speed>=80 && speed<=100)
   {
   return BitmapDescriptor.hueMagenta;
     
   }else if(speed>=100 && speed<=120)
   {
   return BitmapDescriptor.hueOrange;
     
   }else if(speed>=120 && speed<=150)
   {
   return BitmapDescriptor.hueRed;
     
   }  
 else{
   return BitmapDescriptor.hueRose;
 }
   }
     getTime(int speed)  {
   if(speed >=0 && speed <= 20)
   {
     return 60;
     }
   else if(speed >20 && speed<=30)
   {
   return 50;
   }
   else if(speed>=30 && speed<=50)
   {
   return 40;
     
   }else if(speed>=50 && speed<=80)
   {
   return 30;
     
   }else if(speed>=80 && speed<=100)
   {
   return 20;
     
   }else if(speed>=100 && speed<=120)
   {
   return 10;
     
   }else if(speed>=120 && speed<=150)
   {
   return 5;
     
   }  
 else{
   return 2;
 }
   }
  
}