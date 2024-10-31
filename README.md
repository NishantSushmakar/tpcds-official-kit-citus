# tpcds-official-kit-citus

This Project is implemented as a part of INFO-H-419: Data Warehouses course at ULB, supervised by  Prof. Esteban Zimányi. 

Implemented by: Sara Saad, Marwah Sulaiman, Nishant Sushmakar, and Olha Baliasina.

The project aims to perform the [TPC-DS benchmark](https://www.tpc.org/tpcds/default5.asp) on Citus Database (a Postgres distributed extension) locally installed on MacOS machine. 

- Runtime of all queries are reported [here](tpcdskit-official-mac/Results/Queries_runtime.csv) for all scales. The csv file includes the 99 original queries followed by the 6 optimized ones for each of the 4 scales. 

In order to replicate our steps, the following should be done:


1. Clone this repository, cd to the [tools](tpcdskit-official-mac/tools) directory in terminal, and execute this command:

	 	 make OS=MACOS

2. Install Citus locally on the machine by following section 3.6 Citus Cluster Setup in the report. 

3. Generate the Data, using this command in terminal (Ensure that your present working directory is tools):
  
  		./dsdgen -scale 1 -dir ../Data/1GB -verbose y -terminate n
  
		  notes: 
		  - you can use your preferred destination directory (option -dir), and make sure it exists before executing the command.
		  - here we are generating 1GB data, same command will be used to generate bigger scales with only changing the scale and dir options.

4. Create the tables according to TPC-DS schema, set the distribution and reference tables, and load the data, by running the script schema_and_load.sh located [here](tpcdskit-official-mac/Scripts).

	notes:
	- make sure the paths in SQL_FILES and DATA_DIR mentioned in the script correspond to the paths of the files on your machine.
	- make sure the DB_NAME and MASTER_PORT are similar to the ones used in the Citus setup in point 2.
	- a file 'execution_times.txt' will be produced after the script runs. It contains the time taken for each step and for loading every table.

5. Run the queries against your DB by running the script query_execution_file.sh located [here](tpcdskit-official-mac/Scripts)., and with passing path of this [sql file](tpcdskit-official-mac/Queries/1GB/query_0_step_3_after_optimisation.sql) containing the queries as an argument.

		Example: In terminal in Scripts directory:
		./query_execution_file.sh ../Queries/1GB/Final_Queries.sql
		
		notes:
		- make sure the DB info in the script are similar to the ones used in the Citus setup in point 2.
		- a file 'query_analysis.csv' will be produced after the script runs. It contains the status and runtime of every query.



- Steps 3 to 5 can be repeated for different scales.




   


   


