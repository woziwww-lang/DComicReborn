# CopyManga API Comparison: Android App vs Web Version

## Investigation Date
February 25, 2026

## Summary
This document compares the API usage between CopyManga's Android app and web version. The Android app API structure was successfully analyzed from the codebase, while the web version proved challenging to capture due to server-side rendering architecture.

## Android App API (from codebase analysis)

### Base URLs
- Primary: `https://api.mangacopy.com/`
- Alternative: `https://api.copy-manga.com/`
- Dynamic URL selection based on network status check

### Request Headers (Android App)
```
user-agent: COPY/2.3.6
source: copyApp
platform: 3
referer: com.copymanga.app-2.3.6
authorization: Token {token} (or just "Token" if not logged in)
deviceinfo: SM-S9280-e3q
webp: 1
dt: {current_date in format yyyy.mm.dd}
accept: application/json
version: 2.3.6
region: 1
device: V417IR
umstring: b4c89ca4104ea9a97750314d791520ac
host: {dynamic host from base URL}
```

### Key API Endpoints (Android)
1. **Get Comic Detail**: `/api/v3/comic2/{comicId}?in_mainland=true&platform=3`
2. **Get Chapters**: `/api/v3/comic/{comicId}/group/{groupName}/chapters?limit={limit}&offset={page}&in_mainland=true&platform=3`
3. **Get Chapter Content**: `/api/v3/comic/{comicId}/chapter2/{chapterId}?in_mainland=true&platform=3`
4. **Search**: `/api/v3/search/comic?limit={limit}&offset={offset}&q_type=&q={keyword}&platform=3`
5. **Homepage**: `/api/v3/h5/homeIndex`
6. **Rankings**: `/api/v3/ranks?type=1&date_type={dateType}&limit={limit}&offset={offset}`
7. **Latest Updates**: `/api/v3/update/newest?limit={limit}&offset={offset}`
8. **User Subscriptions**: `/api/v3/member/collect/comics?free_type=1&limit={limit}&offset={offset}&_update=true&ordering=-datetime_updated`
9. **Comments**: `/api/v3/comments?comic_id={comicId}&limit={limit}&offset={offset}`
10. **Network Status**: `/api/v3/system/network2?platform=3`

### Authentication (Android)
- Uses Token-based authentication
- Header: `authorization: Token {token}`
- Login endpoint: `/api/v3/login` (POST with FormData)
- Password encoding: Base64 encode of `{password}-{random_salt}`

## Web Version API

### Observations from Browser Investigation
1. **Architecture**: The website (https://www.mangacopy.com/) appears to be heavily server-side rendered
2. **Initial Page Load**: Minimal client-side API calls on homepage
3. **API Base**: Likely uses different endpoints than the Android app
4. **Tested Endpoint**: `/api/kb/web/recommend?pos_type=0` - returned 404

### Expected Web Headers (typical for web applications)
```
User-Agent: Mozilla/5.0 (standard browser user agent)
Referer: https://www.mangacopy.com/
Accept: application/json, text/javascript, */*; q=0.01
Origin: https://www.mangacopy.com
```

### Key Differences Identified

| Aspect | Android App | Web Version |
|--------|-------------|-------------|
| API Base URL | `https://api.mangacopy.com/` | Likely `https://www.mangacopy.com/api/` or embedded |
| Platform Header | `platform: 3` | Not used or different value |
| User-Agent | `COPY/2.3.6` | Standard browser UA |
| Source Header | `source: copyApp` | Likely `source: web` or not used |
| Referer | `com.copymanga.app-2.3.6` | `https://www.mangacopy.com/` |
| Device Info | Included (SM-S9280-e3q, V417IR) | Not used |
| Architecture | RESTful API with JSON responses | Mix of SSR and API calls |

## Recommendations for Web API Implementation

If you need to adapt the Android API for web use, consider:

1. **Change Platform Parameter**: Use `platform=1` or `platform=0` for web (seen in login endpoint)
2. **Update Headers**:
   - `user-agent`: Use standard browser user agent
   - `source`: Change to `web` or `freeSite` (seen in login)
   - `referer`: Use `https://www.mangacopy.com/` or specific page URL
   - Remove device-specific headers: `deviceinfo`, `device`
3. **Keep Essential Headers**:
   - `authorization`: Token-based auth still needed
   - `version`, `region`, `webp`: May still be required
4. **Test API Endpoints**: The Android API endpoints may work with modified headers
5. **Consider CORS**: Web browsers enforce CORS, so direct API calls from browser may be blocked

## Notes

- The web version likely uses a mix of server-side rendering and client-side API calls
- Some API calls may only trigger during specific user actions (pagination, chapter reading, etc.)
- The Android app makes extensive use of the `/api/v3/` namespace
- All Android API requests include `platform=3` query parameter for most endpoints

## Investigation Limitations

Due to the website's server-side rendering architecture, direct observation of web API calls through browser DevTools was not fully successful on the homepage. A more comprehensive analysis would require:
1. Navigating to manga detail pages and chapter reading pages
2. Intercepting API calls during user interactions (scrolling, pagination, etc.)
3. Examining the website's JavaScript bundles for API endpoint definitions
4. Testing various endpoint combinations with different header configurations

## Code Reference

Android API implementation: `/workspace/lib/requests/copymanga/copymanga_request.dart`
