using CP;
int nLocation=...;	  //number of coverage
int AreaWidth=...;    //one side of square
int Horizen =...;     //Planning horizen in minutes
int MaxAirTime= ...;  //Max air-time
int ChargingTime=...; //Battery ChargingTime time
int nVehicle= nLocation * 2; 
range Vehicles = 1..nVehicle;
range Locations = 1..nLocation;
range Location2 = 0..nLocation;
int InitialMissionCompleteTime[n in Locations]=...;
int VehicleLocation[Vehicles]=...;
int   nCharger = ...; //...;// ftoi(round(nLocation/3))+1;
range Chargers = 1..nCharger;
//execute {writeln(nVehicle, " ", nCharger);};


tuple t_task {
key string task;  
key int n;
key int t;  
	int x;
	int y;     
	int s;  
	int e;  		 
};
{t_task} Tasks=...;
{t_task} Task={ t | t in Tasks: t.task=="charge"};

execute { 
for(var v=1;v<=nCharger;v++) {
    Task.add("start", 0, v,0,0,0,0);
    Task.add("return", 0, v*10,0,0,0,0);}
 }
     
tuple t_Travel {
	key int n1;
	key int n2;
	int tt;
}; {t_Travel} Travel=...; 

tuple t_node {
key int n;
	int x;
	int y;      
};
{t_node} Nodes=...; 

//int MaxDist=max(t in Travel: t.n1==0) t.tt*nMeeting*nLocation;
int Dist[l1 in Location2][l2 in Location2]=item(Travel,<l1, l2>).tt; 


execute {
  cp.param.TimeLimit    = 180;
  cp.param.LogVerbosity = 21; 
  cp.param.OptimalityTolerance=0.0000001;
  cp.param.RelativeOptimalityTolerance=0.0000001;    
  cp.param.SearchConfiguration = 36864;  
}

dvar interval vUsed[Chargers] optional;
dvar interval itvJob[t in Task];

dvar interval itvJ2C[Task][Chargers] optional;
dvar sequence seqCharger[c in Chargers] 
in 	  	all(t in Task) itvJ2C[t,c]
types 	all(t in Task)  t.n;

dexpr int ChargerUsed = sum(c in Chargers) presenceOf(vUsed[c]);
dexpr float totDistance =
        sum(c in Chargers, t in Task) 
        Dist[t.n][typeOfNext(seqCharger[c], itvJ2C[t,c], t.n, t.n)];
		//item(Travel,<l, typeOfNext(seqCharger[c], itvM2C[m][l][c], 1, 1) >).tt;

//minimize staticLex(ChargerUsed, totDistance); 
minimize (totDistance+nCharger*10000);
constraints {   
forall(t in Task) 
  if(t.task=="charge")
 {
  	startOf(itvJob[t])== t.s;
  	endOf(itvJob[t])== t.e;
 }  	
 	

forall(t in Task)
alternative(itvJob[t], all(c in Chargers) itvJ2C[t,c]);
  
forall(c in Chargers) noOverlap(seqCharger[c], Travel,true);

forall(c in Chargers) forall(t in Task: t.task=="start") 
	first(seqCharger[c], itvJ2C[t,c]);
forall(c in Chargers) forall(t in Task: t.task=="return") 
	last(seqCharger[c], itvJ2C[t,c]);

}

execute {
writeln("v" + "\t" + "task" + "\t" + "loc"+"\t" + "s"+"\t"+ "e");
for (var c in Chargers)for (var  t in Task)  
	if (itvJ2C[t][c].present) 
	   writeln(c +"\t"+ t.task +"\t"+ t.n +"\t"+ itvJ2C[t][c].start +"\t" + itvJ2C[t][c].end);
   
} 

/*
using CP;
int nLocation=...;	  //number of coverage
int AreaWidth=...;    //one side of square
int Horizen =...;     //Planning horizen in minutes
int MaxAirTime= ...;  //Max air-time
int ChargingTime=...; //Battery ChargingTime time
int nVehicle= nLocation * 2; 
range Vehicles = 1..nVehicle;
range Locations = 1..nLocation;
int InitialMissionCompleteTime[n in Locations]=...;
int VehicleLocation[Vehicles]=...;
int   nCharger = 3;//...;// ftoi(round(nLocation/3))+1;
range Chargers = 1..nCharger;
//execute {writeln(nVehicle, " ", nCharger);};


tuple t_task {
key string task;  
key int n;
key int t;  
	int x;
	int y;     
	int s;  
	int e;  		 
};
{t_task} Tasks=...;
{t_task} Task={ t | t in Tasks: t.task=="charge"};

tuple t_Travel {
	key int n1;
	key int n2;
	int tt;
}; {t_Travel} Travel=...; 

tuple t_node {
key int n;
	int x;
	int y;      
};
{t_node} Nodes=...; 

//int MaxDist=max(t in Travel: t.n1==0) t.tt*nMeeting*nLocation;
int Dist[l1 in Locations][l2 in Locations]=item(Travel,<l1, l2>).tt; 


execute {
  cp.param.TimeLimit    = 180;
  cp.param.LogVerbosity = 21; 
 // cp.param.Workers      = 32; 
}

dvar interval vUsed[Chargers] optional;
dvar interval itvJob[t in Task] in t.s..t.e size t.e-t.s;
dvar interval itvJ2C[Task][Chargers] optional;
dvar interval itvChargerInit[Chargers] in -1..0 size 1;
dvar sequence seqCharger[c in Chargers] 
in 	  append(	all(t in Task) itvJ2C[t,c], 
         	 	all(dummy in 1..1) itvChargerInit[c])
types append(	all(t in Task)  t.n, 
				all(dummy in 1..1) 0);

dexpr int ChargerUsed = sum(c in Chargers) presenceOf(vUsed[c]);
dexpr float totDistance =
        sum(c in Chargers, t in Task) 
        Dist[t.n][typeOfNext(seqCharger[c], itvJ2C[t,c], t.n, t.n)];
		//item(Travel,<l, typeOfNext(seqCharger[c], itvM2C[m][l][c], 1, 1) >).tt;

//minimize staticLex(ChargerUsed, totDistance); 
minimize (totDistance);
constraints {   
forall(t in Task)
alternative(itvJob[t], all(c in Chargers) itvJ2C[t,c]);
  
forall(c in Chargers) 
noOverlap(seqCharger[c], Travel,true);

//forall(c in Chargers) forall(t in Task)
//c6:	presenceOf(vUsed[c]) >= presenceOf(itvJ2C[t,c]);

}

execute {
writeln("v" + "\t" + "task" + "\t" + "loc"+"\t" + "s"+"\t"+ "e");
for (var c in Chargers)for (var  t in Task)  
	if (itvJ2C[t][c].present) 
	   writeln(c +"\t"+ "charge"+"\t"+ t.n +"\t"+ itvJ2C[t][c].start +"\t" + itvJ2C[t][c].end);
   
} 
  
using CP;
int nLocation=...;	  //number of coverage
int AreaWidth=...;    //one side of square
int Horizen =...;     //Planning horizen in minutes
int MaxAirTime= ...;  //Max air-time
int ChargingTime=...; //Battery ChargingTime time
int nVehicle= nLocation * 2; 
range Vehicles = 1..nVehicle;
range Locations = 1..nLocation;
int VehicleLocation[Vehicles]=...;
int InitialMissionCompleteTime[n in Locations]=...;
int  nMeeting = ftoi(round(Horizen/MaxAirTime*1.5)) + ftoi(round(Horizen/MaxAirTime*ChargingTime/MaxAirTime));
range Meetings = 1..nMeeting;
int   nCharger = ftoi(round(nLocation/3))+1;
range Chargers = 1..nCharger;
execute {writeln(nCharger);};

tuple t_task {
key string task;  
key int n;
key int t;  
	int x;
	int y;     
	int s;  
	int e;  		 
};
{t_task} Tasks=...;

tuple t_Travel {
	key int n1;
	key int n2;
	int tt;
}; {t_Travel} Travel=...; 

tuple t_node {
key int n;
	int x;
	int y;      
};
{t_node} Nodes=...; 

//int MaxDist=max(t in Travel: t.n1==0) t.tt*nMeeting*nLocation;
int Dist[l1 in Locations][l2 in Locations]=item(Travel,<l1, l2>).tt; 


execute {
  cp.param.TimeLimit    = 180;
  cp.param.LogVerbosity = 21; 
 // cp.param.Workers      = 32; 
}

dvar interval vUsed[Chargers] optional;
dvar interval itvM[m in Meetings][l in Locations] optional in 0..Horizen+ChargingTime ;
dvar interval itvM2C[m in Meetings][l in Locations][c in Chargers] optional;
dvar interval itvChargerInit[Chargers] in -1..0 size 1;
dvar sequence seqCharger[c in Chargers] 
in 	  append(	all(m in Meetings, l in Locations) itvM2C[m,l,c], 
         	 	all(dummy in 1..1) itvChargerInit[c])
types append(	all(m in Meetings, l in Locations) l, 
				all(dummy in 1..1) 0);
				
cumulFunction cumVehBattery[l in Locations] = 
	step(0, InitialMissionCompleteTime[l]) 
	- sum(h in 1..ftoi(round(Horizen/20))) step(h*20,20)
	+ sum(m in Meetings, c in Chargers) stepAtStart(itvM2C[m,l,c],60,MaxAirTime);

dexpr int ChargerUsed = sum(c in Chargers) presenceOf(vUsed[c]);
dexpr float totDistance =
        sum(c in Chargers, m in Meetings, l in Locations) 
        Dist[l][typeOfNext(seqCharger[c], itvM2C[m,l,c], l, l)];
		//item(Travel,<l, typeOfNext(seqCharger[c], itvM2C[m][l][c], 1, 1) >).tt;

 
//minimize staticLex(ChargerUsed, totDistance); 
minimize (ChargerUsed);

constraints {
  ChargerUsed==3;
forall(m in Meetings, l in Locations)
c1:	presenceOf(itvM[m,l]) => sizeOf(itvM[m,l])==ChargingTime;
	   
forall(m in Meetings, l in Locations)
c2:	alternative(itvM[m,l], all(c in Chargers) itvM2C[m,l,c]);
  
forall(v in Locations)
c3:  cumVehBattery[v]<=MaxAirTime;

forall(c in Chargers) 
c4: noOverlap(seqCharger[c], Travel,true);

forall(c in Chargers, m in Meetings, l in Locations)
c5:  presenceOf(vUsed[c]) >= presenceOf(itvM2C[m,l,c]);
forall(c in 1..nCharger-1) //breaking symmetry
c6:  presenceOf(vUsed[c])>=presenceOf(vUsed[c+1]);
}

execute {
writeln("v" + "\t" + "task" + "\t" + "loc"+"\t" + "s"+"\t"+ "e");
for (var c in Chargers)for (var  m in Meetings)for (var  l in Locations)  
	if (itvM2C[m][l][c].present) 
	   writeln(c +"\t"+ "charge"+"\t"+ l +"\t"+ itvM2C[m][l][c].start +"\t" + itvM2C[m][l][c].end);
   
} 
  

*/