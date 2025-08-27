this is backend api documentation for HiAnime website. all endpoints are prefixed with /api/v2/hianime
https://aniwatch-api-taupe-eight.vercel.app/ -- this is the base url for the api

GET Anime Home Page
Endpoint
/api/v2/hianime/home
Request Sample
const resp = await fetch("/api/v2/hianime/home");
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    genres: ["Action", "Cars", "Adventure", ...],
    latestEpisodeAnimes: [
      {
        id: string,
        name: string,
        poster: string,
        type: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
    spotlightAnimes: [
      {
        id: string,
        name: string,
        jname: string,
        poster: string,
        description: string,
        rank: number,
        otherInfo: string[],
        episodes: {
          sub: number,
          dub: number,
        },
      },
      {...},
    ],
    top10Animes: {
      today: [
        {
          episodes: {
            sub: number,
            dub: number,
          },
          id: string,
          name: string,
          poster: string,
          rank: number
        },
        {...},
      ],
      month: [...],
      week: [...]
    },
    topAiringAnimes: [
      {
        id: string,
        name: string,
        jname: string,
        poster: string,
      },
      {...},
    ],
    topUpcomingAnimes: [
      {
        id: string,
        name: string,
        poster: string,
        duration: string,
        type: string,
        rating: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
    trendingAnimes: [
      {
        id: string,
        name: string,
        poster: string,
        rank: number,
      },
      {...},
    ],
    mostPopularAnimes: [
      {
        id: string,
        name: string,
        poster: string,
        type: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
    mostFavoriteAnimes: [
      {
        id: string,
        name: string,
        poster: string,
        type: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
    latestCompletedAnimes: [
      {
        id: string,
        name: string,
        poster: string,
        type: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
  }
}
🔼 Back to Top

GET Anime A-Z List
Endpoint
/api/v2/hianime/azlist/{sortOption}?page={page}
Path Parameters
Parameter	Type	Description	Required?	Default
sortOption	string	The az-list sort option. Possible values include: "all", "other", "0-9" and all english alphabets .	Yes	--
Query Parameters
Parameter	Type	Description	Required?	Default
page	number	The page number of the result.	No	1
Request Sample
const resp = await fetch("/api/v2/hianime/azlist/0-9?page=1");
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    sortOption: "0-9",
    animes: [
      {
        id: string,
        name: string,
        jname: string,
        poster: string,
        duration: string,
        type: string,
        rating: string,
        episodes: {
          sub: number ,
          dub: number
        }
      },
      {...}
    ],
    totalPages: 1,
    currentPage: 1,
    hasNextPage: false
  }
}
🔼 Back to Top

GET Anime Qtip Info
Endpoint
/api/v2/hianime/qtip/{animeId}
Query Parameters
Parameter	Type	Description	Required?	Default
animeId	string	The unique anime id (in kebab case).	Yes	--
Request Sample
const resp = await fetch("/api/v2/hianime/qtip/one-piece-100");
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    anime: {
      id: "one-piece-100",
      name: "One Piece",
      malscore: string,
      quality: string,
      episodes: {
        sub: number,
        dub: number
      },
      type: string,
      description: string,
      jname: string,
      synonyms: string,
      aired: string,
      status: string,
      genres: ["Action", "Adventure", "Comedy", "Drama", "Fantasy", "Shounen", "Drama", "Fantasy", "Shounen", "Fantasy", "Shounen", "Shounen", "Super Power"]
    }
  }
}
🔼 Back to Top

GET Anime About Info
Endpoint
/api/v2/hianime/anime/{animeId}
Query Parameters
Parameter	Type	Description	Required?	Default
animeId	string	The unique anime id (in kebab case).	Yes	--
Request Sample
const resp = await fetch("/api/v2/hianime/anime/attack-on-titan-112");
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    anime: [
      info: {
        id: string,
        name: string,
        poster: string,
        description: string,
        stats: {
          rating: string,
          quality: string,
          episodes: {
            sub: number,
            dub: number
          },
          type: string,
          duration: string
        },
        promotionalVideos: [
          {
            title: string | undefined,
            source: string | undefined,
            thumbnail: string | undefined
          },
          {...},
        ],
        characterVoiceActor: [
          {
            character: {
              id: string,
              poster: string,
              name: string,
              cast: string
            },
            voiceActor: {
              id: string,
              poster: string,
              name: string,
              cast: string
            }
          },
          {...},
        ]
      }
      moreInfo: {
        aired: string,
        genres: ["Action", "Mystery", ...],
        status: string,
        studios: string,
        duration: string
        ...
      }
    ],
    mostPopularAnimes: [
      {
        episodes: {
          sub: number,
          dub: number,
        },
        id: string,
        jname: string,
        name: string,
        poster: string,
        type: string
      },
      {...},
    ],
    recommendedAnimes: [
      {
        id: string,
        name: string,
        poster: string,
        duration: string,
        type: string,
        rating: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
    relatedAnimes: [
      {
        id: string,
        name: string,
        poster: string,
        duration: string,
        type: string,
        rating: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
    seasons: [
      {
        id: string,
        name: string,
        title: string,
        poster: string,
        isCurrent: boolean
      },
      {...}
    ]
  }
}
🔼 Back to Top

GET Search Results
Endpoint
# basic example
/api/v2/hianime/search?q={query}&page={page}

# advanced example
/api/v2/hianime/search?q={query}&page={page}&genres={genres}&type={type}&sort={sort}&season={season}&language={sub_or_dub}&status={status}&rated={rating}&start_date={yyyy-mm-dd}&end_date={yyyy-mm-dd}&score={score}
Query Parameters
Parameter	Type	Description	Required?	Default
q	string	The search query, i.e. the title of the item you are looking for.	Yes	--
page	number	The page number of the result.	No	1
type	string	Type of the anime. eg: movie	No	--
status	string	Status of the anime. eg: finished-airing	No	--
rated	string	Rating of the anime. eg: r+ or pg-13	No	--
score	string	Score of the anime. eg: good or very-good	No	--
season	string	Season of the aired anime. eg: spring	No	--
language	string	Language category of the anime. eg: sub or sub-&-dub	No	--
start_date	string	Start date of the anime(yyyy-mm-dd). eg: 2014-10-2	No	--
end_date	string	End date of the anime(yyyy-mm-dd). eg: 2010-12-4	No	--
sort	string	Order of sorting the anime result. eg: recently-added	No	--
genres	string	Genre of the anime, separated by commas. eg: isekai,shounen	No	--
[!TIP] For both start_date and end_date, year must be mentioned. If you wanna omit date or month specify 0 instead. Eg: omitting date -> 2014-10-0, omitting month -> 2014-0-12, omitting both -> 2014-0-0

Request Sample
// basic example
const resp = await fetch("/api/v2/hianime/search?q=titan&page=1");
const data = await resp.json();
console.log(data);

// advanced example
const resp = await fetch(
    "/api/v2/hianime/search?q=girls&genres=action,adventure&type=movie&sort=score&season=spring&language=dub&status=finished-airing&rated=pg-13&start_date=2014-0-0&score=good"
);
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    animes: [
      {
        id: string,
        name: string,
        poster: string,
        duration: string,
        type: string,
        rating: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
    mostPopularAnimes: [
      {
        episodes: {
          sub: number,
          dub: number,
        },
        id: string,
        jname: string,
        name: string,
        poster: string,
        type: string
      },
      {...},
    ],
    currentPage: 1,
    totalPages: 1,
    hasNextPage: false,
    searchQuery: string,
    searchFilters: {
      [filter_name]: [filter_value]
      ...
    }
  }
}
🔼 Back to Top

GET Search Suggestions
Endpoint
/api/v2/hianime/search/suggestion?q={query}
Query Parameters
Parameter	Type	Description	Required?	Default
q	string	The search suggestion query.	Yes	--
Request Sample
const resp = await fetch("/api/v2/hianime/search/suggestion?q=monster");
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    suggestions: [
      {
        id: string,
        name: string,
        poster: string,
        jname: string,
        moreInfo: ["Jan 21, 2022", "Movie", "17m"]
      },
      {...},
    ]
  }
}
🔼 Back to Top

GET Producer Animes
Endpoint
/api/v2/hianime/producer/{name}?page={page}
Path Parameters
Parameter	Type	Description	Required?	Default
name	string	The name of anime producer (in kebab case).	Yes	--
Query Parameters
Parameter	Type	Description	Required?	Default
page	number	The page number of the result.	No	1
Request Sample
const resp = await fetch("/api/v2/hianime/producer/toei-animation?page=2");
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    producerName: "Toei Animation Anime",
    animes: [
      {
        id: string,
        name: string,
        poster: string,
        duration: string,
        type: string,
        rating: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
    top10Animes: {
      today: [
        {
          episodes: {
            sub: number,
            dub: number,
          },
          id: string,
          name: string,
          poster: string,
          rank: number
        },
        {...},
      ],
      month: [...],
      week: [...]
    },
    topAiringAnimes: [
      {
        episodes: {
          sub: number,
          dub: number,
        },
        id: string,
        jname: string,
        name: string,
        poster: string,
        type: string
      },
      {...},
    ],
    currentPage: 2,
    totalPages: 11,
    hasNextPage: true
  }
}
🔼 Back to Top

GET Genre Animes
Endpoint
/api/v2/hianime/genre/{name}?page={page}
Path Parameters
Parameter	Type	Description	Required?	Default
name	string	The name of anime genre (in kebab case).	Yes	--
Query Parameters
Parameter	Type	Description	Required?	Default
page	number	The page number of the result.	No	1
Request Sample
const resp = await fetch("/api/v2/hianime/genre/shounen?page=2");
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    genreName: "Shounen Anime",
    animes: [
      {
        id: string,
        name: string,
        poster: string,
        duration: string,
        type: string,
        rating: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
    genres: ["Action", "Cars", "Adventure", ...],
    topAiringAnimes: [
      {
        episodes: {
          sub: number,
          dub: number,
        },
        id: string,
        jname: string,
        name: string,
        poster: string,
        type: string
      },
      {...},
    ],
    currentPage: 2,
    totalPages: 38,
    hasNextPage: true
  }
}
🔼 Back to Top

GET Category Animes
Endpoint
/api/v2/hianime/category/{name}?page={page}
Path Parameters
Parameter	Type	Description	Required?	Default
category	string	The category of anime.	Yes	--
Query Parameters
Parameter	Type	Description	Required?	Default
page	number	The page number of the result.	No	1
Request Sample
// categories -> "most-favorite", "most-popular", "subbed-anime", "dubbed-anime", "recently-updated", "recently-added", "top-upcoming", "top-airing", "movie", "special", "ova", "ona", "tv", "completed"

const resp = await fetch("/api/v2/hianime/category/tv?page=2");
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    category: "TV Series Anime",
    animes: [
      {
        id: string,
        name: string,
        poster: string,
        duration: string,
        type: string,
        rating: string,
        episodes: {
          sub: number,
          dub: number,
        }
      },
      {...},
    ],
    genres: ["Action", "Cars", "Adventure", ...],
    top10Animes: {
      today: [
        {
          episodes: {
            sub: number,
            dub: number,
          },
          id: string,
          name: string,
          poster: string,
          rank: number
        },
        {...},
      ],
      month: [...],
      week: [...]
    },
    currentPage: 2,
    totalPages: 100,
    hasNextPage: true
  }
}
🔼 Back to Top

GET Estimated Schedules
Endpoint
/api/v2/hianime/schedule?date={date}
Query Parameters
Parameter	Type	Description	Required?	Default
date	string	The date of the desired schedule in the following format: (yyyy-mm-dd).	Yes	--
Request Sample
const resp = await fetch("/api/v2/hianime/schedule?date=2024-06-09");
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    scheduledAnimes: [
      {
        id: string,
        time: string, // 24 hours format
        name: string,
        jname: string,
        airingTimestamp: number,
        secondsUntilAiring: number
      },
      {...}
    ]
  }
}
🔼 Back to Top

GET Anime Episodes
Endpoint
/api/v2/hianime/anime/{animeId}/episodes
Path Parameters
Parameter	Type	Description	Required?	Default
animeId	string	The unique anime id.	Yes	--
Request Sample
const resp = await fetch("/api/v2/hianime/anime/steinsgate-3/episodes");
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    totalEpisodes: 24,
    episodes: [
      {
        number: 1,
        title: "Turning Point",
        episodeId: "steinsgate-3?ep=213"
        isFiller: false,
      },
      {...}
    ]
  }
}
🔼 Back to Top

GET Anime Next Episode Schedule
Endpoint
/api/v2/hianime/anime/{animeId}/next-episode-schedule
Path Parameters
Parameter	Type	Description	Required?	Default
animeId	string	The unique anime id.	Yes	--
Request Sample
const resp = await fetch(
    "/api/v2/hianime/anime/steinsgate-3/next-episode-schedule"
);
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    airingISOTimestamp: string | null,
    airingTimestamp: number | null,
    secondsUntilAiring: number | null
  }
}
🔼 Back to Top

GET Anime Episode Servers
Endpoint
/api/v2/hianime/episode/servers?animeEpisodeId={id}
Query Parameters
Parameter	Type	Description	Required?	Default
animeEpisodeId	string	The unique anime episode id.	Yes	--
Request Sample
const resp = await fetch(
    "/api/v2/hianime/episode/servers?animeEpisodeId=steinsgate-0-92?ep=2055"
);
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    episodeId: "steinsgate-0-92?ep=2055",
    episodeNo: 5,
    sub: [
      {
        serverId: 4,
        serverName: "vidstreaming",
      },
      {...}
    ],
    dub: [
      {
        serverId: 1,
        serverName: "megacloud",
      },
      {...}
    ],
    raw: [
      {
        serverId: 1,
        serverName: "megacloud",
      },
      {...}
    ]
  }
}
🔼 Back to Top

if the first frame dont work then use this  GET Anime Episode Streaming Links
Endpoint
/api/v2/hianime/episode/sources?animeEpisodeId={id}?server={server}&category={dub || sub || raw}
Query Parameters
Parameter	Type	Description	Required?	Default
animeEpisodeId	string	The unique anime episode id.	Yes	--
server	string	The name of the server.	No	"hd-1"
category	string	The category of the episode ('sub', 'dub' or 'raw').	No	"sub"
Request Sample
const resp = await fetch(
    "/api/v2/hianime/episode/sources?animeEpisodeId=steinsgate-3?ep=230&server=hd-1&category=dub"
);
const data = await resp.json();
console.log(data);
Response Schema
{
  success: true,
  data: {
    headers: {
      Referer: string,
      "User-Agent": string,
      ...
    },
    sources: [
      {
        url: string, // .m3u8 hls streaming file
        isM3U8: boolean,
        quality?: string,
      },
      {...}
    ],
    subtitles: [
      {
        lang: "English",
        url: string, // .vtt subtitle file
      },
      {...}
    ],
    anilistID: number | null,
    malID: number | null
  }
}