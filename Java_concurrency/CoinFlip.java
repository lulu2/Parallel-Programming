import java.util.*;
import java.io.*;

public class CoinFlip implements Runnable{
int thread_id;
static int num_thread;
static long section;
static long sectionHead[];
Random generator = new Random();

CoinFlip(int id)
{this.thread_id=id;}

public int trial()
{int result = generator.nextInt(2);
return result;}

public void run() 
{long temp = 0;
 for (int i=0;i<section;i++){if(trial()==1){temp++;}}
 sectionHead[thread_id] = temp;}
	
public static void main( String[] args ){
long head=0;
num_thread=Integer.parseInt(args[0]);
long total = Long.parseLong(args[1]);
section=total/((long) num_thread);
sectionHead=new long[num_thread];

long start = System.currentTimeMillis();
Thread[] threads = new Thread[num_thread];
for ( int i=0; i<num_thread; i++ ){
	threads[i] = new Thread( new CoinFlip(i) );
	threads[i].start();}
for( int j=0; j<num_thread; j++){
	try
	{threads[j].join();
	head = head + sectionHead[j];}
	catch(InterruptedException e)
	{System.out.println("Thread interrupted.  Exception: " + e.toString() + " Message: " + e.getMessage()) ;
	return;}
	}
long end = System.currentTimeMillis();

System.out.println(head+" heads in "+args[1]+" coin tosses");
System.out.println("Elapsed time: " + ((end - start)) + "ms");
}
}






