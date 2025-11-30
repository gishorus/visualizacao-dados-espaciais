############################################################
# FUNÇÕES PARA TRABALHAR COM OPENSTREETMAP NO R
# Funções genéricas reutilizáveis para qualquer cidade
############################################################

# Carrega pacotes necessários
suppressPackageStartupMessages({
  library(osmdata)
  library(sf)
  library(dplyr)
})

# ---------------------------------------------------------
# Função: Malha viária (linhas)
# ---------------------------------------------------------
get_malha_viaria <- function(cidade, crs = 31982, tipos_via = NULL) {
  message(paste(" Baixando malha viária de:", cidade))
  
  consulta <- opq(bbox = cidade) |>
    add_osm_feature(key = "highway")
  
  dados <- osmdata_sf(consulta)
  lin <- dados$osm_lines
  
  if (is.null(lin) || nrow(lin) == 0) {
    warning("️  Nenhuma via encontrada")
    return(NULL)
  }
  
  message(paste("   ", nrow(lin), "vias encontradas"))
  
  if (!is.null(tipos_via)) {
    lin <- lin[lin$highway %in% tipos_via, ]
    message(paste("    Filtrado:", nrow(lin), "vias"))
  }
  
  if (!is.null(crs)) {
    lin <- st_transform(lin, crs)
  }
  
  return(lin)
}

# ---------------------------------------------------------
# Função: Edifícios (polígonos)
# ---------------------------------------------------------
get_edificios <- function(cidade, crs = 31982, tipo_edificio = NULL) {
  message(paste(" Baixando edifícios de:", cidade))
  
  consulta <- opq(bbox = cidade) |>
    add_osm_feature(key = "building")
  
  dados <- osmdata_sf(consulta)
  poligonos <- dados$osm_polygons
  
  if (is.null(poligonos) || nrow(poligonos) == 0) {
    warning("️  Nenhum edifício encontrado")
    return(NULL)
  }
  
  message(paste("   ", nrow(poligonos), "edifícios encontrados"))
  
  if (!is.null(tipo_edificio)) {
    poligonos <- poligonos[poligonos$building %in% tipo_edificio, ]
    message(paste("    Filtrado:", nrow(poligonos), "edifícios"))
  }
  
  if (!is.null(crs)) {
    poligonos <- st_transform(poligonos, crs)
  }
  
  return(poligonos)
}

# ---------------------------------------------------------
# Função: Pontos de interesse (POI)
# ---------------------------------------------------------
get_poi <- function(cidade, tipo, crs = 31982) {
  message(paste(" Baixando POI:", tipo))
  
  consulta <- opq(bbox = cidade) |>
    add_osm_feature(key = "amenity", value = tipo)
  
  dados <- osmdata_sf(consulta)
  pontos <- dados$osm_points
  
  if (is.null(pontos) || nrow(pontos) == 0) {
    warning(paste("️  Nenhum", tipo, "encontrado"))
    return(NULL)
  }
  
  message(paste("   ", nrow(pontos), "pontos"))
  
  if (!is.null(crs)) {
    pontos <- st_transform(pontos, crs)
  }
  
  return(pontos)
}

# ---------------------------------------------------------
# Função: Áreas verdes
# ---------------------------------------------------------
get_areas_verdes <- function(cidade, crs = 31982) {
  message(paste(" Baixando áreas verdes de:", cidade))
  
  consulta <- opq(bbox = cidade) |>
    add_osm_feature(key = "leisure", value = "park")
  
  dados <- osmdata_sf(consulta)
  poligonos <- dados$osm_polygons
  
  if (is.null(poligonos) || nrow(poligonos) == 0) {
    warning("  Nenhum parque encontrado")
    return(NULL)
  }
  
  message(paste("   ", nrow(poligonos), "parques"))
  
  if (!is.null(crs)) {
    poligonos <- st_transform(poligonos, crs)
  }
  
  return(poligonos)
}

# ---------------------------------------------------------
# Função genérica OSM (flexível)
# ---------------------------------------------------------
get_osm_feature <- function(cidade, key, value = NULL, 
                            crs = 31982, tipo_geom = "all") {
  msg <- paste("🔍 Baixando:", key)
  if (!is.null(value)) msg <- paste(msg, "=", value)
  message(msg)
  
  consulta <- opq(bbox = cidade)
  
  if (is.null(value)) {
    consulta <- add_osm_feature(consulta, key = key)
  } else {
    consulta <- add_osm_feature(consulta, key = key, value = value)
  }
  
  dados <- osmdata_sf(consulta)
  
  resultado <- switch(tipo_geom,
                      "points"   = dados$osm_points,
                      "lines"    = dados$osm_lines,
                      "polygons" = dados$osm_polygons,
                      "all"      = list(
                        points   = dados$osm_points,
                        lines    = dados$osm_lines,
                        polygons = dados$osm_polygons
                      )
  )
  
  if (!is.list(resultado) && !is.null(crs) && !is.null(resultado)) {
    resultado <- st_transform(resultado, crs)
  }
  
  return(resultado)
}

# ---------------------------------------------------------
# Resumo estatístico
# ---------------------------------------------------------
resumir_osm <- function(objeto_sf, nome = "Camada") {
  if (is.null(objeto_sf)) {
    cat(paste(" ", nome, ": sem dados\n"))
    return(invisible(NULL))
  }
  
  cat(paste("\n ", nome, "\n"))
  cat(paste("   • Feições:", nrow(objeto_sf), "\n"))
  cat(paste("   • CRS:", st_crs(objeto_sf)$input, "\n"))
  cat(paste("   • Geometria:", 
            paste(unique(st_geometry_type(objeto_sf)), collapse = ", "), "\n"))
  
  bbox <- st_bbox(objeto_sf)
  cat("   • Extensão:\n")
  cat(paste("      X:", round(bbox$xmin, 2), "→", round(bbox$xmax, 2), "\n"))
  cat(paste("      Y:", round(bbox$ymin, 2), "→", round(bbox$ymax, 2), "\n"))
  
  return(invisible(objeto_sf))
}

# ---------------------------------------------------------
# Função de exportação segura
# ---------------------------------------------------------
exportar_camada <- function(objeto_sf, arquivo, camada_nome) {
  if (is.null(objeto_sf) || nrow(objeto_sf) == 0) {
    message(paste("️  Pulando:", camada_nome, "(sem dados)"))
    return(invisible(FALSE))
  }
  
  tryCatch({
    st_write(
      objeto_sf, arquivo, layer = camada_nome,
      delete_layer = TRUE, quiet = TRUE
    )
    message(paste(" ", camada_nome, "→", basename(arquivo)))
    return(invisible(TRUE))
  }, error = function(e) {
    warning(paste("  Erro:", camada_nome, "-", e$message))
    return(invisible(FALSE))
  })
}

cat(" Funções OSM carregadas com sucesso!\n")