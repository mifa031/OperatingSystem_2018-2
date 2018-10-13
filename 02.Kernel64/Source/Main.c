#include "Types.h"

void kPrintString( int iX, int iY, const char* pcString );
void kPrintStringMove( int iX, int iY, const char* pcString );

void Main( void )
{
//// read-only page test ////
//	DWORD* testAddr = (DWORD*)0x1ff000;
//	testAddr[0] = 1;

	kPrintString( 0, 12, "Switch To IA-32e Mode Success~!!" );
    kPrintString( 0, 13, "IA-32e C Language Kernel Start..............[Pass]" );
	kPrintStringMove(0,14,"This message is printed through the video memory relocated to 0xAB8000");
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
