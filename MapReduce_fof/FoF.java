import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import java.util.ArrayList;

public class FoF{

public static class FoFMapper extends Mapper<Object, Text, Text, Text>{
private Text Mapvalues = new Text();
private Text Mapkeys = new Text();

public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
	StringTokenizer itr = new StringTokenizer(value.toString());
	String name = itr.nextToken();
	ArrayList<String> flist = new ArrayList<String>();
        String temp=itr.nextToken();
	while (itr.hasMoreTokens()) {
	String ones = itr.nextToken();
	temp=temp+"-"+ones;
	flist.add(ones);
	}

for (String f: flist){
Mapkeys.set(name+"-"+f);
Mapvalues.set(temp);
context.write(Mapkeys, Mapvalues);
Mapkeys.set(f+"-"+name);
context.write(Mapkeys, Mapvalues);
}
}
}

public static class FoFReducer extends Reducer<Text, Text, Text, Text> {
private Text Outputss=new Text();
private Text Outputsskey=new Text();
public void reduce(Text key, Iterable<Text> values,Context context) throws IOException, InterruptedException {
String keyss=key.toString();
String[] keysss=keyss.split("-");
String key1=keysss[0];
String key2=keysss[1];
int ii=0;
String line1="";
String line2="";
for (Text lineline:values){
if (ii==0){
line1=lineline.toString();
}
else{
line2=lineline.toString();
}
ii++;
}
String[] flist1=line1.split("-");
String[] flist2=line2.split("-");

for (String a: flist1){
	for (String b: flist2){
		if (a.equals(b)){
			int c=Integer.parseInt(key2);
			int d=Integer.parseInt(a);
			if (c<d){
				Outputss.set(key1+" "+key2);
				Outputsskey.set(a);
				context.write(Outputss,Outputsskey);
			}
		}
	}
}
}
}

public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
    Job job = Job.getInstance(conf, "Frend of Friend");
    job.setJarByClass(FoF.class);
    job.setMapperClass(FoFMapper.class);
    job.setReducerClass(FoFReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(Text.class);
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
  }
}


