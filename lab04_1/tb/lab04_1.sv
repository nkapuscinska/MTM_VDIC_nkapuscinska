//`define DEBUG

function real abs_func(input real x);
    return (x < 0) ? -x : x;
endfunction


class shape_c;
    string name;
    real points[$][2];

    function new(string name, real points[$][2]);
        this.name   = name;
        this.points = points;
    endfunction

    virtual function real get_area();
    endfunction

    virtual function void print();
        $display("--------------------------------------------------------------------------------");
        $display("This is: %s", name);
        foreach (points[i]) begin
            $display(" (%0.2f, %0.2f)", points[i][0], points[i][1]);
        end
        $display("Area is: %0.2f", get_area());
        $display("--------------------------------------------------------------------------------");
    endfunction

endclass


class polygon_c extends shape_c;

    function new(string name, real points[$][2]);
        super.new(name, points);
    endfunction

    // Shoelace formula
    function real get_area();
        real area;
        int n = points.size();
        int i;
        area = 0;

        for (i = 0; i < n; i++) begin
            int j = (i + 1) % n;
            area += (points[i][0] * points[j][1]) - (points[j][0] * points[i][1]);
        end

        return 0.5 * abs_func(area);
    endfunction
endclass

class rectangle_c extends polygon_c;

    function new(string name, real points[4][2]);
        super.new(name, points);
    endfunction
endclass

class triangle_c extends polygon_c;

    function new(string name, real points[3][2]);
        super.new(name, points);
    endfunction
endclass


class circle_c extends shape_c;

    function new(string name, real points[2][2]);
        super.new(name, points);
    endfunction

    function real get_radius();
        real dx, dy;
        dx = points[1][0] - points[0][0];
        dy = points[1][1] - points[0][1];
        return $sqrt(dx*dx + dy*dy);
    endfunction

    function real get_area();
        real r = get_radius();
        return 3.14159265358979 * r * r;
    endfunction

    function void print();
        real r = get_radius();
        $display("--------------------------------------------------------------------------------");
        $display("This is: circle");
        $display(" (%0.2f, %0.2f)", points[0][0], points[0][1]);
        $display(" radius: %0.2f", r);
        $display("Area is: %0.2f", get_area());
        $display("--------------------------------------------------------------------------------");
    endfunction

endclass


class shape_reporter #(type T = shape_c);

    protected static T shape_storage[$];

    static function void push_shape(T obj);
        shape_storage.push_back(obj);
    endfunction

    static function void report_shapes();

        if (shape_storage.size() == 0) begin
            $display("No shapes stored.\n");
            return;
        end

        $display("\n================ REPORT =================");

        foreach (shape_storage[i]) begin
            shape_storage[i].print();
        end
        $display("==========================================\n");
    endfunction

endclass


class shape_factory;

    static function shape_c make_shape(real pts[$][2]);
        shape_c obj;

        case (pts.size())
            2: begin
                circle_c c = new("circle", pts);
                obj = c;
            end

            3: begin
                triangle_c t = new("triangle", pts);
                obj = t;
            end

            4: begin
                if (is_rectangle(pts)) begin
                    rectangle_c r = new("rectangle", pts);
                    obj = r;
                end else begin
                    polygon_c p = new("polygon", pts);
                    obj = p;
                end
            end

            default: begin
                polygon_c p = new("polygon", pts);
                obj = p;
            end
        endcase
        return obj;
    endfunction

    static function bit is_rectangle(real p[$][2]);
        real dx, dy;
        dx = abs_func(p[1][0] - p[0][0]);
        dy = abs_func(p[1][1] - p[0][1]); 

        if (dx != 0 && dy != 0)
            return 1;
        else
            return 0;
    endfunction

endclass

module top;
    int fd;
    string line;
    shape_c s;
    shape_factory sf = new();
    shape_reporter#(shape_c) sr = new();

    initial begin        
        fd = $fopen("lab04part1_shapes.txt", "r");
        if (!fd) begin
            $display("ERROR: Cannot open file!");
            $finish;
        end

        while ($fgets(line, fd)) begin
            real nums[$];
            real pts[$][2];
            int i;

            nums.delete();
            pts.delete();
            parse_points(line, nums);

`ifdef DEBUG
            $display("line: %s", line);
            $display("nums size: %0d", nums.size());
`endif
            
            for (i = 0; i < nums.size()/2; i++) begin
                pts.push_back('{nums[2*i], nums[2*i + 1]});
`ifdef DEBUG
                $display("Point %0d: (%0.2f, %0.2f)", i, nums[2*i], nums[2*i + 1]);
`endif
            end          

            s = sf.make_shape(pts);
            sr.push_shape(s);
            
        end
            
            sr.report_shapes();
        $fclose(fd);

        
        $finish;
    end

   function automatic void parse_points(string line, ref real values[$]);
        real val;
        int sp;
        string token;

        values.delete();
            begin
                automatic string num_str;
                for (int i = 0; i < line.len(); i++) begin
                    while (i < line.len() && (line[i] inside {" ", "\t", "\n", "\r"})) begin
                        i++;
                    end
                    if (i >= line.len()) break;
                    num_str = "";

                    while (i < line.len() && (line[i] inside {"-", "."} || line[i] inside {["0" : "9"]})) begin
                        num_str = {num_str, line[i]};
                        i++;
                    end

                    if (num_str.len() > 0) begin
                        values.push_back(num_str.atoreal());
                    end

                    i--;
                end
            end
    endfunction

endmodule
