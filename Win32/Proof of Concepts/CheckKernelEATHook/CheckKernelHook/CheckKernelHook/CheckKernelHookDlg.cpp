
// CheckKernelHookDlg.cpp : 实现文件
//

#include "stdafx.h"
#include "CheckKernelHook.h"
#include "CheckKernelHookDlg.h"
#include "afxdialogex.h"
#include "AddService.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#endif


HANDLE g_hDevice = NULL;

typedef struct
{
	WCHAR*     szTitle;           //列表的名称
	int		  nWidth;            //列表的宽度

}COLUMNSTRUCT;
COLUMNSTRUCT g_Column_Data_Online[] = 
{
	{L"原始地址",			    148	},
	{L"函数名称",			150	},
	{L"Hook地址",	160	},
	{L"模块名称",		300	},
	{L"模块基址",			    80	},
	{L"模块大小",		    81	},
	{L"类型",			81	}
};

int g_Column_Count_Online = 7; //列表的个数
int g_Column_Online_Width = 0; 


// 用于应用程序“关于”菜单项的 CAboutDlg 对话框

class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

// 对话框数据
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持

// 实现
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()


// CCheckKernelHookDlg 对话框




CCheckKernelHookDlg::CCheckKernelHookDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CCheckKernelHookDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CCheckKernelHookDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_LIST, m_List);
}

BEGIN_MESSAGE_MAP(CCheckKernelHookDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
END_MESSAGE_MAP()


// CCheckKernelHookDlg 消息处理程序

BOOL CCheckKernelHookDlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	// 将“关于...”菜单项添加到系统菜单中。

	// IDM_ABOUTBOX 必须在系统命令范围内。
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		BOOL bNameValid;
		CString strAboutMenu;
		bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
		ASSERT(bNameValid);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// 设置此对话框的图标。当应用程序主窗口不是对话框时，框架将自动
	//  执行此操作
	SetIcon(m_hIcon, TRUE);			// 设置大图标
	SetIcon(m_hIcon, FALSE);		// 设置小图标

	m_List.SetExtendedStyle(LVS_EX_FULLROWSELECT);
	for (int i = 0; i < g_Column_Count_Online; i++)
	{
		m_List.InsertColumn(i, g_Column_Data_Online[i].szTitle,LVCFMT_CENTER,g_Column_Data_Online[i].nWidth);

		g_Column_Online_Width+=g_Column_Data_Online[i].nWidth;  
	}


	//LoadDrv(L"CheckKernelHook");

	g_hDevice = OpenDevice(L"\\\\.\\CheckKernelHookLinkName");
	if (g_hDevice==(HANDLE)-1)
	{
		MessageBox(L"打开设备失败");
		return TRUE;
	}

	


	CheckKernelHook();
	
	return TRUE;  // 除非将焦点设置到控件，否则返回 TRUE
}

VOID CCheckKernelHookDlg::CheckKernelHook()
{
	ULONG_PTR ulCount = 0x1000;
	PINLINEHOOKINFO PInlineHookInfo = NULL;
	BOOL bRet = FALSE;
	DWORD ulReturnSize = 0;
	do 
	{
		ULONG_PTR ulSize = 0;
		if (PInlineHookInfo)
		{
			free(PInlineHookInfo);
			PInlineHookInfo = NULL;
		}
		ulSize = sizeof(INLINEHOOKINFO) + ulCount * sizeof(INLINEHOOKINFO_INFORMATION);
		PInlineHookInfo = (PINLINEHOOKINFO)malloc(ulSize);
		if (!PInlineHookInfo)
		{
			break;
		}
		memset(PInlineHookInfo,0,ulSize);
		bRet = DeviceIoControl(g_hDevice,CTL_CHECKKERNELMODULE,
			NULL,
			0,
			PInlineHookInfo,
			ulSize,
			&ulReturnSize,
			NULL);
		ulCount = PInlineHookInfo->ulCount + 1000;
	} while (bRet == FALSE && GetLastError() == ERROR_INSUFFICIENT_BUFFER);

	if(PInlineHookInfo->ulCount==0)
	{
		MessageBox(L"当前内核安全",L"");
	}
	else
	{
		InsertDataToList(PInlineHookInfo);
	}
	if (PInlineHookInfo)
	{
		free(PInlineHookInfo);
		PInlineHookInfo = NULL;
	}


}

VOID CCheckKernelHookDlg::InsertDataToList(PINLINEHOOKINFO PInlineHookInfo)
{
	CString OrgAddress,CurAddress,ModuleBase,ModuleSize;
	for(int i=0;i<PInlineHookInfo->ulCount;i++)
	{
		OrgAddress.Format(L"0x%p",PInlineHookInfo->InlineHook[i].ulMemoryFunctionBase);
		CurAddress.Format(L"0x%p",PInlineHookInfo->InlineHook[i].ulMemoryHookBase);
		ModuleBase.Format(L"0x%p",PInlineHookInfo->InlineHook[i].ulHookModuleBase);
		ModuleSize.Format(L"%d",PInlineHookInfo->InlineHook[i].ulHookModuleSize);
		int n = m_List.InsertItem(m_List.GetItemCount(),OrgAddress,0);   //注意这里的i 就是Icon 在数组的位置
		CString szFunc=L"";
		CString ModuleName = L"";
		szFunc +=PInlineHookInfo->InlineHook[i].lpszFunction;
		ModuleName += PInlineHookInfo->InlineHook[i].lpszHookModuleImage;
		m_List.SetItemText(n,1,szFunc);
		m_List.SetItemText(n,2,CurAddress);
		m_List.SetItemText(n,3,ModuleName);
		m_List.SetItemText(n,4,ModuleBase);
		m_List.SetItemText(n,5,ModuleSize);
		CString Type= L"";
		if(PInlineHookInfo->InlineHook[i].ulHookType==1)
		{
			Type +=L"SSDT Hook";
		}
		else if(PInlineHookInfo->InlineHook[i].ulHookType==2)
		{
			Type +=L"Next Call Hook";
		}
		else if(PInlineHookInfo->InlineHook[i].ulHookType==0)
		{
			Type +=L"Inline Hook";
		}
		m_List.SetItemText(n,6,Type);
		
	}
	UpdateData(TRUE);
}
void CCheckKernelHookDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialogEx::OnSysCommand(nID, lParam);
	}
}

// 如果向对话框添加最小化按钮，则需要下面的代码
//  来绘制该图标。对于使用文档/视图模型的 MFC 应用程序，
//  这将由框架自动完成。

void CCheckKernelHookDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // 用于绘制的设备上下文

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// 使图标在工作区矩形中居中
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// 绘制图标
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

//当用户拖动最小化窗口时系统调用此函数取得光标
//显示。
HCURSOR CCheckKernelHookDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

