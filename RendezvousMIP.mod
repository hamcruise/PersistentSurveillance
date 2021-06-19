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
int   nCharger =  nLocation;
range Chargers = 1..nCharger;
//execute {writeln(nVehicle, " ", nCharger);};

int bigM=10000;

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

tuple t_task2 {
key int j;  
key int n;
	int x;
	int y;     
	int s;  
	int e;  		 
};
{t_task2} Task={<t.n + t.t, t.n, t.x,t.y,t.s,t.e > | t in Tasks: t.task=="charge"};

tuple t_Travel {
	key int n1;
	key int n2;
	int tt;
}; {t_Travel} Travel=...; 
{t_Travel}  J2J_Travel;

tuple t_node {
key int n;
	int x;
	int y;      
};
{t_node} Nodes=...; 
execute {
  Task.add(0,0,Nodes.get(0).x,Nodes.get(0).y,0,0);
  Task.add(1000,0,Nodes.get(0).x,Nodes.get(0).y,0,0);
};
execute { 
for(var i in Task)	for(var j in Task)
    J2J_Travel.add(i.j,j.j,Travel.get(i.n,j.n).tt );
};

int Dist[t1 in Task][t2 in Task]=item(J2J_Travel,<t1.j, t2.j>).tt; 
int Dist_adj[t1 in Task][t2 in Task];
execute {
  for(var i in Task) for(var j in Task)
	if(i.n==0 && j.n>0) Dist_adj[i][j] = 10000 + J2J_Travel.get(i.j, j.j).tt;
	else       Dist_adj[i][j]  =Dist[i][j];

};

//Add 10000 to all D[0,j]
execute {
	 cplex.tilim = 30;
  	cplex.epagap=0.05;
  	cplex.epgap=0.05; 		 
 }
  
dvar boolean X[Chargers][Task][Task];
dvar int+ B[Chargers][Task];
dexpr float totDistance =
        sum(i,j in Task, v in Chargers) Dist_adj[i][j] * X[v,i,j];
        
minimize totDistance;
subject to {
forall (i in Task: i.n> 0 && i.n< 1000) 
   sum(j in Task, v in Chargers) X[v,i,j] ==1;

forall (v in Chargers, i in Task: i.n> 0 && i.n< 1000)  	
  	sum(j in Task) X[v,j,i]== sum(j in Task) X[v,i,j];

forall (v in Chargers)  sum(i,j in Task: i.j==0) X[v,i,j] == 1;      
forall (v in Chargers)  sum(i,j in Task: j.j==1000) X[v,i,j] == 1;   


//forall (i in Task,v in Chargers) X[v,i,i] ==0;       
//forall (i,j in Task,v in Chargers: i.n==j.n) X[v,i,j] ==0; 
       

forall (i,j in Task, v in Chargers) 
B[v,j] >= B[v,i]+ Dist[i][j]+ChargingTime - bigM * (1-X[v,i,j]) ;
forall(i in Task,v in Chargers: i.n> 0 && i.n< 1000)
		B[v,i] == i.s;
}
execute {

writeln("v"+"\t" + "i" +"\t" + "j"+"\t"+ "n1" +"\t" + "n2" +"\t"+ "dist" +"\t"+ "s" + "\t"+ "e" + "\t"+ "start" );
for (var v in Chargers) for (var i in Task) for (var j in Task)
	if ( X[v][i][j]==1)
      	writeln( v +"\t" + i.j  +"\t"+  j.j +"\t"+ i.n +"\t" + j.n + "\t" + Dist[i][j] 
                 + "\t" + j.s + "\t" + j.e + "\t" + B[v][j] ) ;
} 
        