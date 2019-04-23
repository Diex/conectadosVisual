
int __childDepth = 1;

public void showAllChildren(PShape mc)
{
    int numC = mc.getChildCount();
    String tabStr = "";

    for (int t = 0; t < __childDepth; t++)
    {
        tabStr = tabStr + "\t";
    }

    for(int i = 0; i < numC; i++)
    {
        PShape child = mc.getChild(i); 
        
        println(tabStr + "|" + __childDepth + "|" + mc.getChild(i).getName());

        if (child.getChildCount() > 0)
        {
            __childDepth ++;
            showAllChildren(child);
            __childDepth --;
        }
    }
}
