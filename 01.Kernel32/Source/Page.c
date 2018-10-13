#include "Page.h"

void kInitializePageTables( void )
{
	PML4TENTRY* pstPML4TEntry;
	PDPTENTRY* pstPDPTEntry;
	PDENTRY* pstPDEntry;
	PTENTRY* pstPTEntry;
	DWORD dwMappingAddress;
	int i;

	pstPML4TEntry = ( PML4TENTRY* ) 0x100000;
	kSetPageEntryData( &( pstPML4TEntry[ 0 ] ), 0x00, 0x101000, PAGE_FLAGS_DEFAULT, 0 );
	for( i = 1 ; i < PAGE_MAXENTRYCOUNT ; i++ )
	{
		kSetPageEntryData( &( pstPML4TEntry[ i ] ), 0, 0, 0, 0 );
	}
	
	pstPDPTEntry = ( PDPTENTRY* ) 0x101000;
	for( i = 0 ; i < 64 ; i++ )
	{
		kSetPageEntryData( &( pstPDPTEntry[ i ] ), 0, 0x102000 + ( i * PAGE_TABLESIZE ), PAGE_FLAGS_DEFAULT, 0 );
	}
	for( i = 64 ; i < PAGE_MAXENTRYCOUNT ; i++ )
	{
		kSetPageEntryData( &( pstPDPTEntry[ i ] ), 0, 0, 0, 0 );
	}
	
	pstPDEntry = ( PDENTRY* ) 0x102000;
	for(i=0; i<PAGE_MAXENTRYCOUNT * 64; i++)
	{
		if(i==5){
			kSetPageEntryData(&(pstPDEntry[i]), 0, 0x142000 , PAGE_FLAGS_DEFAULT, 0);
		}else{
		kSetPageEntryData( &( pstPDEntry[ i ] ), 0, 0x142000 + ( i * PAGE_TABLESIZE ), PAGE_FLAGS_DEFAULT, 0 );
		}	
	}


	pstPTEntry = (PTENTRY*) 0x142000;
	dwMappingAddress = 0;
	for( i = 0 ; i < PAGE_MAXENTRYCOUNT * 32768 ; i++ )
	{
	    if(dwMappingAddress == 0x1ff000){
		kSetPageEntryData( &( pstPTEntry[ i ] ), ( i * ( PAGE_DEFAULTSIZE >> 11 ) ) >> 12, dwMappingAddress, PAGE_FLAGS_P, 0 );
		}else{
		kSetPageEntryData( &( pstPTEntry[ i ] ), ( i * ( PAGE_DEFAULTSIZE >> 11 ) ) >> 12, dwMappingAddress, PAGE_FLAGS_DEFAULT, 0 );
		}
		dwMappingAddress += PAGE_DEFAULTSIZE;
	}

}

void kSetPageEntryData( PTENTRY* pstEntry, DWORD dwUpperBaseAddress,
		DWORD dwLowerBaseAddress, DWORD dwLowerFlags, DWORD dwUpperFlags )
{
	pstEntry->dwAttributeAndLowerBaseAddress = dwLowerBaseAddress | dwLowerFlags;
	pstEntry->dwUpperBaseAddressAndEXB = ( dwUpperBaseAddress & 0xFF ) | 
		dwUpperFlags;
}