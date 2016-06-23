REM ******************************************************
REM OddPromotion
REM ******************************************************
Function promotionFromJson(promotion_json As Object) As Object

  promotion = CreateObject("roAssociativeArray")

  promotion.Type = "promotion"
  promotion_attributes = promotion_json.attributes
  promotion.Title = promotion_attributes.title
  promotion.SDImage = promotion_attributes.images.aspect16x9
  promotion.HDImage = promotion_attributes.images.aspect16x9
  promotion.Description = promotion_attributes.description
  promotion.contentID = promotion_json.id

  return promotion

End Function

Function promotionForPosterScreen(promotion As Object) As Object

  poster_promotion = CreateObject("roAssociativeArray")

  ' hacky, but sometimes we need to know what type we are when selected from the list @TQ
  poster_promotion.Type = "promotion"
  poster_promotion.HDPosterUrl           = promotion.HDImage
  poster_promotion.SDPosterUrl           = promotion.SDImage
  poster_promotion.ShortDescriptionLine1 = promotion.Title
  poster_promotion.ShortDescriptionLine2 = "Promotion"

  return poster_promotion

End Function

Function promotionForSpringboardScreen(promotion As Object) As Object

  springboard_promotion = CreateObject("roAssociativeArray")

  springboard_promotion.Title = promotion.Title
  springboard_promotion.SDPosterUrl = promotion.SDImage
  springboard_promotion.HDPosterUrl = promotion.HDImage
  springboard_promotion.Description = promotion.Description
  springboard_promotion.ContentType = "episode"

  return springboard_promotion

End Function

Function promotionForGridScreen(promotion As Object) As Object

  grid_promotion = CreateObject("roAssociativeArray")

  ' hacky, but sometimes we need to know what type we are when selected from the list @TQ
  grid_promotion.Type = "promotion"

  grid_promotion.SDPosterUrl = promotion.SDImage
  grid_promotion.HDPosterUrl = promotion.HDImage
  grid_promotion.ContentType = "episode"
  grid_promotion.ShortDescriptionLine1 = promotion.Title
  grid_promotion.ShortDescriptionLine2 = "Promotion"
  return grid_promotion

End Function
