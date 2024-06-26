import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { useNavigate } from "react-router-dom";
import useContract from "@/hooks/useContract";
import useFileUpload from "@/hooks/useFileUpload";
import { useState } from "react";

import { Progress } from "@/components/ui/progress"

import { FaCheckCircle } from "react-icons/fa";

const profileFormSchema = z.object({
    area: z.string({ required_error: "Please enter area." }),
    survey: z.string({ required_error: "Please enter survey No" }),
    state: z.string(),
    price: z.string({ required_error: "Adhaar number required" }),
    pid: z.string({ required_error: "Pan card number required" }),
    city: z.string({ required_error: "city name required" })
});

type ProfileFormValues = z.infer<typeof profileFormSchema>;

export default function LandRegistrationForm() {
    const navigate = useNavigate()
    const contractInstance: any = useContract()
    const privateKey = localStorage.getItem('key')
    const form = useForm<ProfileFormValues>({
        resolver: zodResolver(profileFormSchema),
        mode: "onChange",
    });
    const [ImageHash, setImageHash] = useState()

    const fileUploader_1 = useFileUpload();
    const fileUploader_2 = useFileUpload();


    async function FormHandler(data: any) {

        try {


            const RegisterLand = await contractInstance.methods.addLand(data.area, data.city, data.state, data.price, data.pid, data.survey, fileUploader_2.documentHash, fileUploader_1.documentHash).send({ from: `${privateKey}`, gas: '2000000', gasPrice: '5000000000' })

            console.log("Transaction receipt:", RegisterLand);
            navigate('/user/dashboard')
        }

        catch (error) {
            console.log(error);
        }

    }


    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit((data) => {
                FormHandler(data);
                // navigate('/user/dashboard')
                console.log(data)
            })} className="space-y-2">
                <FormField
                    control={form.control}
                    name="area"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Area(SqFt)</FormLabel>
                            <FormControl>
                                <Input {...field} style={{ width: "600px" }} />
                            </FormControl>

                            <FormMessage />
                        </FormItem>
                    )}
                />
                <FormField
                    control={form.control}
                    name="city"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>City</FormLabel>
                            <FormControl>
                                <Input {...field} style={{ width: "600px" }} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />
                <FormField
                    control={form.control}
                    name="state"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>State</FormLabel>
                            <FormControl>
                                <Input {...field} style={{ width: "600px" }} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />
                <FormField
                    control={form.control}
                    name="price"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Land Price</FormLabel>
                            <FormControl>
                                <Input {...field} style={{ width: "600px" }} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />
                <FormField
                    control={form.control}
                    name="pid"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>PID</FormLabel>
                            <FormControl>
                                <Input {...field} style={{ width: "600px" }} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />

                <FormField
                    control={form.control}
                    name="survey"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Survey No</FormLabel>
                            <FormControl>
                                <Input {...field} style={{ width: "600px" }} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />
                <div className="grid w-full max-w-sm items-center gap-1.5">
                    <Label htmlFor="picture">Document</Label>
                    <Input onChange={(e) => {
                        fileUploader_1.uploadFile(e.target.files)
                    }} id="document" type="file" />
                    <div className="flex">
                        <Progress value={fileUploader_1.uploadProgress + 1} className="w-[60%]" />
                        {fileUploader_1.uploadProgress === 99 && <FaCheckCircle className="ml-4" />}
                    </div>
                    {/* {fileUploader_1.uploadProgress} */}
                </div>
                <div className="grid w-full max-w-sm items-center gap-1.5">
                    <Label htmlFor="picture">Land Image</Label>
                    <Input onChange={(e) => {
                        fileUploader_2.uploadFile(e.target.files)
                    }} id="picture" type="file" />
                    <div className="flex">
                        <Progress value={fileUploader_2.uploadProgress + 1} className="w-[60%]" />
                        {fileUploader_2.uploadProgress === 99 && <FaCheckCircle className="ml-4" />}
                    </div>
                    {/* {fileUploader_2.uploadProgress} */}
                </div>
                <div className="pt-6">
                    <Button type="submit" disabled={!form.formState.isValid}>Add</Button>
                </div>
            </form>
        </Form>
    );
}
