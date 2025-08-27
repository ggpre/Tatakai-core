import { NextRequest, NextResponse } from 'next/server';

const BASE_URL = 'https://aniwatch-api-taupe-eight.vercel.app/api/v2/hianime';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const endpoint = searchParams.get('endpoint') || '';
    
    // Remove endpoint from searchParams and build query string
    const params = new URLSearchParams(searchParams);
    params.delete('endpoint');
    const queryString = params.toString();
    
    const apiUrl = `${BASE_URL}${endpoint}${queryString ? '?' + queryString : ''}`;
    
    console.log('Fetching from:', apiUrl);
    console.log('Original search params:', searchParams.toString());
    console.log('Endpoint:', endpoint);
    console.log('Query string:', queryString);
    
    const response = await fetch(apiUrl, {
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    });

    console.log('Response status:', response.status);
    console.log('Response headers:', Object.fromEntries(response.headers.entries()));

    if (!response.ok) {
      console.error(`HTTP error! status: ${response.status}`);
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    console.log('API Response received, status:', data.status);
    
    // Transform the response to match our expected structure
    const transformedData = {
      success: data.status === 200,
      data: data.data || data,
      status: data.status
    };
    
    return NextResponse.json(transformedData, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });
  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { 
        success: false,
        error: 'Failed to fetch data', 
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}
