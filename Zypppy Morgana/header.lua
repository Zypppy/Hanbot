return {
  id = "ZypppyMorgana",
  name = "Morgana",
  riot = true,
  flag = {
    text = "Morgana by Zypppy",
    color = {
      text = 0xFFEDD7E6,
      background1 = 0xFFEDBBDC,
      background2 = 0x99000000
    }
  },
  load = function()
    return player.charName == "Morgana"
  end
}