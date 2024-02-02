function onStateLeaved(){
    // just remove the video when the player switched states
    if (public["cutscene_video"] != null){
        public["cutscene_video"].stop();
        public["cutscene_video"].dispose();
    }
}