libname mass "C:\Users\tgriffith\OneDrive - USU\Research Papers\Student Research\Mass Shootings and Stock Prices\data";

proc import out = mass1 datafile = "C:\Users\tgriffith\OneDrive - USU\Research Papers\Student Research\Mass Shootings and Stock Prices\data\mass_shootings_1982_2020.xlsx"
	DBMS = xlsx replace;
run;

data mass2;	
	set mass1;
	*if fatalities ge 10;
	if year(date) le 2019;
	drop summary mental_health_details where_obtained weapon_details weapons_obtained_legally sources mental_health_sources sources_additional_age latitude longitude;
run;
	

data mass3;
	set mass2;
	array parsed_vars(*) $25. city state;
		i=1;
		do while(scan(location, i, ",") ne "");
			parsed_vars(i)=scan(location, i, ",");
			i+1;
		end;
	drop i location;
run;

data mass4;
	set mass3 (rename = (date=event_date));
	match = 1;
run;
 
data crsp;
	set mass.crsp_ins;
		prc = abs(prc);
		if vol gt 0;
		range_volt = log(askhi)-log(bidlo);
		spread = (ask-bid)/(.5*(ask+bid));
		mcap = (prc*(shrout*1000))/1000000;
		match = 1;
	drop COMNAM askhi bidlo ask bid shrout;
	proc sort;by permno date;
run;


* Merge event files with CRSP data;

proc sql;
	create table comb as
	select *
	from mass4, crsp
	where mass4.match = crsp.match and mass4.event_date = crsp.date;
quit;


* Output eventus file for CARs;

data events;
	set comb;
	dates = year(date)*10000+month(date)*100+day(date);
	keep permno dates;
run;

proc export data=events
	outfile = "C:\Users\tgriffith\OneDrive - USU\Research Papers\Student Research\Mass Shootings and Stock Prices\data\test.txt"
	dbms = tab replace;
	putnames = NO;
run;

