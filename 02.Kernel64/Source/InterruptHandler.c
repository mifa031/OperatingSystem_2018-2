#include "InterruptHandler.h"
#include "PIC.h"
#include "Keyboard.h"
#include "Page.h"

static inline void invlpg(void* m);

void pageFaultHandler(int iVectorNumber, QWORD qwErrorCode, DWORD faultAddr)
{
	qwErrorCode = qwErrorCode << 63;
	qwErrorCode = qwErrorCode >> 63;
	if(qwErrorCode == 0)
	{
		kPrintString( 0, 0, "================================================" );
		kPrintString(0, 1, "     Page Fualt Occurs~!    ");
		kPrintString(0, 2, "     Address:");
		kPrintAddr(14, 2, faultAddr);
		kPrintString(0, 3, "================================================" );
	}
	else if(qwErrorCode == 1)
	{
		kPrintString( 0, 0, "================================================" );
		kPrintString(0, 1, "     Protection Fualt Occurs~!    ");
		kPrintString(0, 2, "     Address:");
		kPrintAddr(14, 2, faultAddr);
		kPrintString(0, 3, "================================================" );

	}

	PTENTRY* pstPTEntry = (PTENTRY*)0x142000;
	DWORD dwUpperAddress = faultAddr >> 32;
	QWORD tempAddr = faultAddr << 32;
    DWORD dwMappingAddress = tempAddr >> 32;
	DWORD entry = faultAddr / 4096;
	kResetPageEntryData( &( pstPTEntry[ entry ] ), ( entry * ( PAGE_DEFAULTSIZE >> 11 ) ) >> 12, dwMappingAddress, PAGE_FLAGS_DEFAULT, 0 );
	invlpg(faultAddr);
}

static inline void invlpg(void* m)
{
	    /* Clobber memory to avoid optimizer re-ordering access before invlpg, which may cause nasty bugs. */
	    asm volatile ( "invlpg (%0)" : : "b"(m) : "memory" );
}

void kCommonExceptionHandler( int iVectorNumber, QWORD qwErrorCode )
{
    char vcBuffer[ 3 ] = { 0, };

    vcBuffer[ 0 ] = '0' + iVectorNumber / 10;
    vcBuffer[ 1 ] = '0' + iVectorNumber % 10;

    kPrintString( 0, 0, "================================================" );
    kPrintString( 0, 1, "                 Exception Occur~!!!!               " );
    kPrintString( 0, 2, "                    Vector:                         " );
    kPrintString( 27, 2, vcBuffer );
    kPrintString( 0, 3, "================================================" );

    while( 1 ) ;
}

void kCommonInterruptHandler( int iVectorNumber )
{
    char vcBuffer[] = "[INT:  , ]";
    static int g_iCommonInterruptCount = 0;

    vcBuffer[ 5 ] = '0' + iVectorNumber / 10;
    vcBuffer[ 6 ] = '0' + iVectorNumber % 10;
    vcBuffer[ 8 ] = '0' + g_iCommonInterruptCount;
    g_iCommonInterruptCount = ( g_iCommonInterruptCount + 1 ) % 10;
    kPrintString( 70, 0, vcBuffer );

    kSendEOIToPIC( iVectorNumber - PIC_IRQSTARTVECTOR );
}

void kKeyboardHandler( int iVectorNumber )
{
    char vcBuffer[] = "[INT:  , ]";
    static int g_iKeyboardInterruptCount = 0;
    BYTE bTemp;

    vcBuffer[ 5 ] = '0' + iVectorNumber / 10;
    vcBuffer[ 6 ] = '0' + iVectorNumber % 10;
    vcBuffer[ 8 ] = '0' + g_iKeyboardInterruptCount;
    g_iKeyboardInterruptCount = ( g_iKeyboardInterruptCount + 1 ) % 10;
    kPrintString( 0, 0, vcBuffer );

    if( kIsOutputBufferFull() == TRUE )
    {
        bTemp = kGetKeyboardScanCode();
        kConvertScanCodeAndPutQueue( bTemp );
    }

    kSendEOIToPIC( iVectorNumber - PIC_IRQSTARTVECTOR );
}
