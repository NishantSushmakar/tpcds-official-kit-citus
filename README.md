# tpcds-official-kit-citus

This Project is implemented as a part of INFO-H-419: Data Warehouses course at ULB, supervised by  Prof. Esteban Zimányi. 

The project aims to implement the TPC-DS benchmark on Citus Database (a Postgres distributed extension) locally installed on MacOS machine. In order to replicate our steps, the following should be done:


1. Clone this repository, cd to the tools directory in terminal, and execute this command:

  make OS=MACOS

2. Install Citus locally on the machine by following section 3.6 Citus Cluster Setup in the report. 

3. Generate the Data, using this command in terminal (in tools directory too):
  
  ./dsdgen -scale 1 -dir ../Data/1GB -verbose y -terminate n
  
  notes: 
  - you can use your preferred destination directory (option -dir), and make sure it exists before executing the command.
  - here we are generating 1GB data, same command will be used to generate bigger scales.

4. Create the tables according to TPC-Ds schema, set the distribution and reference tables, and load the data, using the script schema_and_load.sh in [this directory](/tpcds-official-kit-citus/tpcdskit-official-mac/Scripts)


