package cz.kle.tabulka;

import android.os.Bundle;
import org.apache.cordova.*;

public class Tabulka extends CordovaActivity 
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        super.init();
        super.loadUrl(Config.getStartUrl());
    }
}
