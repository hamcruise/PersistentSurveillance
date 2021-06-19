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
dvar interval itvJob[j in Tasks] in j.s..j.e size j.e-j.s;
dvar interval itvJ2V[j in Tasks][Vehicles] optional;
dvar interval itvVehicleInit[Vehicles] in -1..0 size 1;
dvar boolean vUsed[Vehicles];

dvar sequence seqVeh[v in Vehicles] 
in 	  append(	all(j in Tasks: j.task=="on") itvJ2V[j][v], 
				all(j in Tasks: j.task=="charge") itvJ2V[j][v],
         	 	all(dummy in 1..1) itvVehicleInit[v])
types append(	all(j in Tasks: j.task=="on") j.n,
				all(j in Tasks: j.task=="charge") 0,
				all(dummy in 1..1) VehicleLocation[v]);

dvar sequence seqLoc[n in Locations] 
in 	  all(j in Tasks: j.n==n && j.task=="on") itvJob[j];

execute {
  cp.param.TimeLimit = 30;
  cp.param.LogVerbosity=21; 
  cp.param.Workers=1; 
  cp.param.OptimalityTolerance=0.0000001;
  cp.param.RelativeOptimalityTolerance=0.0000001;    
  }

///*
minimize sum(v in Vehicles) vUsed[v];
constraints {
forall(t in Tasks)
c1:	alternative(itvJob[t], all(v in Vehicles) itvJ2V[t][v]);
forall(v in Vehicles) forall(t1,t2 in Tasks: t1.n==t2.n && t1.t*100==t2.t && t1.e < Horizen) 
c2:   presenceOf(itvJ2V[t1][v]) == presenceOf(itvJ2V[t2][v]); 
 
c3b:forall(j in Tasks: j.s==0) presenceOf(itvJ2V[j][j.n])==1;
c4: forall(v in Vehicles) noOverlap(seqVeh[v], Travel);

forall(v in Locations) noOverlap(seqLoc[v]);

forall(v in Vehicles) forall(t in Tasks)
c6:	vUsed[v] >= presenceOf(itvJ2V[t][v]);
forall(v in 1..nVehicle-1)
c7:  vUsed[v]>=vUsed[v+1];
}
//*/

execute {
 
writeln("v" + "\t" + "task" + "\t" + "loc"+"\t" + "s"+"\t"+ "e");
for (var t in Tasks)for (var v in Vehicles) 
	if (itvJ2V[t][v].present) 
		for (var l in Locations)
			if(t.n==l && t.task=="on")
				   writeln(v +"\t"+ "mission"+"\t"+ l +"\t"+ itvJ2V[t][v].start +"\t" + itvJ2V[t][v].end );
				   
for (var t in Tasks)for (var v in Vehicles) 
	if (itvJ2V[t][v].present) 
			if(t.t>=100 && t.task=="charge")
				   writeln(v +"\t"+ "charge"+"\t"+ 0 +"\t"+ itvJ2V[t][v].start +"\t" + itvJ2V[t][v].end);
   
} 
