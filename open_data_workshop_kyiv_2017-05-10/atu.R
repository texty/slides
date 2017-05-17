library(rvest)

page <- html_session('http://atu.minregion.gov.ua/ua/ustriydo2015')

#get names----------------------------------------------------------------------

regions <- page %>% 
  html_nodes('.text-left a:nth-child(1)') %>% 
  html_text() %>% 
  trimws()

regions <- regions[nchar(regions)>0]

#get urls-----------------------------------------------------------------------

regions_urls <- page %>% 
  html_nodes('.text-left a:nth-child(1)') %>% 
  html_attr('href')

regions_urls <- regions_urls[!is.na(regions_urls)]

#combine into dataframe---------------------------------------------------------

regions_df <- data.frame(names = regions, urls = regions_urls)

#get subregions-----------------------------------------------------------------

subregions <- data.frame()

for (i in 1:nrow(regions_df)) {
  
  url <- paste0('http://atu.minregion.gov.ua', regions_df$urls[i])
  
  page <- html_session(url)
  
  regions <- page %>% 
    html_nodes('.ad-center-on-map+ a') %>% 
    html_text()
  
  regions <- regions[nchar(regions)>0]
  
  regions_url<- page %>% 
    html_nodes('.ad-center-on-map+ a') %>% 
    html_attr('href')
  
  regions_urls <- regions_urls[!is.na(regions_urls)]
  
  df <- data.frame(region = regions_df$names[i], subregions = regions, subregions_url = regions_url)
  
  subregions <- rbind.data.frame(subregions, df)
  
  Sys.sleep(1)

}

#get geometry-------------------------------------------------------------------

library(httr)

request = GET('http://atu.minregion.gov.ua/api/format/region_template/ato.ato_level_territory_view/atoid/27/wkb_geometry,name_fullua')

response = content(request, as = 'parsed')

coordinates <- response$data$wkb_geometry

#get geometry-------------------------------------------------------------------

library(httr)
library(jsonlite)

request = GET('http://atu.minregion.gov.ua/api/format/region_template/ato.ato_level_territory_view/atoid/27/wkb_geometry,name_fullua')

response = content(request, as = 'text')

response_json = fromJSON(response)

coordinates <- as.data.frame(matrix(response_json$data$wkb_geometry$coordinates, 
                      byrow = F, 
                      ncol = 2))

