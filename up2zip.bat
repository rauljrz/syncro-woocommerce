REM "E:\project\ratnik\develop\idea\instalador\portable\with 7z\7zr" 

rem 7z a -xr@.ideas/exclude7z.txt %date:~6,4%%date:~3,2%%date:~0,2% @.ideas/listfile.txt

7z a -xr@.ideas/exclude7z.txt %date:~10,4%%date:~4,2%%date:~7,2% @.ideas/listfile.txt
