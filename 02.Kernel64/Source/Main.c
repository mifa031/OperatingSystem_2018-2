#include "Types.h"
#include "Keyboard.h"
#include "Descriptor.h"
#include "PIC.h"

void kPrintString( int iX, int iY, const char* pcString );
void kPrintStringMove( int iX, int iY, const char* pcString );

void Main( void )
{
	char vcTemp[2] = {0,};
	BYTE bFlags;
	BYTE bTemp;
	int i=0;
	KEYDATA stData;

	kPrintString( 0, 12, "Switch To IA-32e Mode Success~!!" );
    kPrintString( 0, 13, "IA-32e C Language Kernel Start..............[Pass]" );
	kPrintStringMove(0,14,"This message is printed through the video memory relocated to 0xAB8000");
	
	kPrintString( 0, 15, "GDT Initialize And Switch For IA-32e Mode...[    ]" );
	kInitializeGDTTableAndTSS();
	kLoadGDTR( GDTR_STARTADDRESS );
	kPrintString( 45, 15, "Pass" );

    kPrintString( 0, 16, "TSS Segment Load............................[    ]" );
	kLoadTR( GDT_TSSSEGMENT );
	kPrintString( 45, 16, "Pass" );

	kPrintString( 0, 17, "IDT Initialize..............................[    ]" );
	kInitializeIDTTables();
	kLoadIDTR( IDTR_STARTADDRESS );
	kPrintString( 45, 17, "Pass" );

	
	kPrintString(0, 18, "Keyboard Activate And Queue Initialize......[    ]");

	if(kInitializeKeyboard() == TRUE)
	{
		kPrintString(45,18,"Pass");
		kChangeKeyboardLED(FALSE, FALSE, FALSE);
	}
	else
	{
		kPrintString(45,18,"Fail");
		while(1);
	}

	kPrintString(0,19,"PIC Controller And Interrupt Initialize.....[    ]");
	kInitializePIC();
	kMaskPICInterrupt(0);
	kEnableInterrupt();
	kPrintString(45,19,"Pass");
	
	while(1)
	{
		if(kGetKeyFromKeyQueue(&stData) == TRUE)
		{
			if(stData.bFlags & KEY_FLAGS_DOWN)
			{
				vcTemp[0] = stData.bASCIICode;
				kPrintString(i++, 20, vcTemp);
				if(vcTemp[0] == '0')
				{
					//// page fault test ////
					DWORD* testAddr = (DWORD*)0x1ff000;
					DWORD read_test = testAddr[0]; // read test
					testAddr[0] = 1; // write test
				}
			}
		}
	}
}

void kPrintString( int iX, int iY, const char* pcString )
{
    CHARACTER* pstScreen = ( CHARACTER* ) 0xB8000;
    int i;
    
    pstScreen += ( iY * 80 ) + iX;

    for( i = 0 ; pcString[ i ] != 0 ; i++ )
    {
        pstScreen[ i ].bCharactor = pcString[ i ];
    }
}

void kPrintAddr(int iX, int iY, QWORD addr)
{
	QWORD pre_temp;
	QWORD temp;
	int is_pre_zero = 1;
	kPrintString(iX, iY, "0x");
	char* print_char[2] = {0,0};
	for(int i=0, j=0; i<16; i++){
		pre_temp = temp;
		temp = addr;
		temp = temp << (i*4);
		temp = temp >> 60;
		if((pre_temp== 0) && (temp != 0) && (is_pre_zero == 1)){
			is_pre_zero = 0;
		}
		if(is_pre_zero == 0){
			if(temp > 9){ // alphabet
				temp += 0x37;
			}else{        // number
				temp += 0x30;
			}
			char temp_char = (char)temp;
			print_char[0] = temp_char;
			kPrintString(iX + 2 + j,iY,print_char);
			j++;
		}
	}
}

void kPrintStringMove( int iX, int iY, const char* pcString )
{
    CHARACTER* pstScreen = ( CHARACTER* ) 0xAB8000;
    int i;
    
    pstScreen += ( iY * 80 ) + iX;

    for( i = 0 ; pcString[ i ] != 0 ; i++ )
    {
        pstScreen[ i ].bCharactor = pcString[ i ];
    }
}
